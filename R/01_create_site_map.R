# =============================================================================
# Create Site Location Map
# =============================================================================
# This script creates a map showing study site locations with Montreal boundary
# =============================================================================

# Load setup and data
source("R/00_setup.R")

cat("\n=== CREATING SITE LOCATION MAP ===\n\n")

# -----------------------------------------------------------------------------
# 1. LOAD SITE DATA
# -----------------------------------------------------------------------------

# Load sites shapefile
sites <- st_read("data/sites_shp/sites_coordinates.shp")

# Check the structure
print(head(sites))
print(names(sites))

# -----------------------------------------------------------------------------
# 2. GET MONTREAL BOUNDARY
# -----------------------------------------------------------------------------

# Create directory for Montreal polygons
dir.create("data/mtl_polygones", showWarnings = FALSE)

# Download Montreal terrestrial boundary if not already present
if (!file.exists("data/mtl_polygones/limites-terrestres.geojson")) {
  cat("Downloading Montreal boundary...\n")
  download.file(
    url = "https://donnees.montreal.ca/dataset/b628f1da-9dc3-4bb1-9875-1470f891afb1/resource/92cb062a-11be-4222-9ea5-867e7e64c5ff/download/limites-terrestres.geojson",
    destfile = "data/mtl_polygones/limites-terrestres.geojson"
  )
}

# Load Montreal boundary
mtl <- read_sf("data/mtl_polygones/limites-terrestres.geojson")

# Transform to same CRS as sites
mtl <- st_transform(mtl, st_crs(sites))

cat("✓ Montreal boundary loaded\n")
cat("  Montreal CRS:", st_crs(mtl)$input, "\n\n")

# -----------------------------------------------------------------------------
# 3. DOWNLOAD AND PROCESS RIVER DATA
# -----------------------------------------------------------------------------

# Download rivers and water bodies from Natural Resources Canada if not present
if (!file.exists("data/mtl_polygones/RHN/RHN_0210001_3_2_HD_REGIONHYDRO_2.shp")) {
  cat("Downloading river data...\n")
  download.file(
    url = "https://ftp.geogratis.gc.ca/pub/nrcan_rncan/vector/geobase_nhn_rhn/shp_fr/02/nhn_rhn_0210001_shp_fr.zip",
    destfile = "data/mtl_polygones/nhn_rhn_0210001_shp_fr.zip"
  )
  unzip("data/mtl_polygones/nhn_rhn_0210001_shp_fr.zip",
        exdir = "data/mtl_polygones/RHN")
  unlink("data/mtl_polygones/nhn_rhn_0210001_shp_fr.zip")
}

# Load and process river data
riv <- read_sf("data/mtl_polygones/RHN/RHN_0210001_3_2_HD_REGIONHYDRO_2.shp") %>%
  st_transform(st_crs(sites)) %>%
  dplyr::filter(DEFINITION %in% c(1, 5, 6)) %>%
  st_union() %>%
  st_crop(st_buffer(st_union(mtl), 10000))

cat("✓ River data loaded and processed\n\n")

# -----------------------------------------------------------------------------
# 4. CREATE MAP
# -----------------------------------------------------------------------------
cat("Creating map...\n")

# Define map extent based on sites with buffer
buffer_distance <- 3000  # in meters
sites_bbox <- st_bbox(st_buffer(sites, buffer_distance))

# Create the map with river layer
p_map <- ggplot() +
  geom_sf(data = riv, fill = "lightblue", color = "steelblue", linewidth = 0.3)


# Create island labels
island_labels <- data.frame(
  name = c("Montréal\nIsland", "Bizard\nIsland"),
  x = c(-73.6, -73.899),  # Longitude
  y = c(45.55, 45.491)     # Latitude
) %>%
  st_as_sf(coords = c("x", "y"), crs = 4326) %>%
  st_transform(st_crs(sites))

# Add site locations and map elements
p_map <- p_map +
  # Add site locations
  geom_sf(data = sites, fill = "black", color = "black", linewidth = 0.5) +
  # Add island labels
  geom_sf_text(data = island_labels, aes(label = name),
               size = 4, fontface = "italic", color = "black") +
  # Set map extent to zoomed area around sites
  coord_sf(xlim = c(sites_bbox["xmin"], sites_bbox["xmax"]),
           ylim = c(sites_bbox["ymin"], sites_bbox["ymax"])) +
  # Add north arrow
  annotation_north_arrow(
    location = "br",
    pad_y = unit(1, "cm"),
    which_north = "true",
    style = north_arrow_fancy_orienteering,
    height = unit(1.5, "cm"),
    width = unit(1.5, "cm")
  ) +
  # Add scale bar
  annotation_scale(
    location = "br",
    width_hint = 0.3,
    style = "ticks"
  ) +
  # Styling
  theme_minimal() +
  theme(
    panel.grid = element_line(color = "grey90", linewidth = 0.2),
    panel.border = element_rect(color = "black", fill = NA, linewidth = 1),
    axis.text = element_text(size = 9),
    axis.title = element_blank()
  ) 

# Print the map
print(p_map)

# -----------------------------------------------------------------------------
# 5. CREATE QUEBEC INSET MAP
# -----------------------------------------------------------------------------

# Get Quebec boundary
canada <- ne_states(country = "canada", returnclass = "sf")
quebec <- canada %>% filter(name == "Québec")

# Transform to same CRS as sites
quebec <- st_transform(quebec, st_crs(sites))

# Create bounding box for study area
study_area_box <- st_as_sfc(st_bbox(riv), crs = st_crs(riv))

# Create label for Quebec
quebec_centroid <- st_centroid(quebec)
quebec_label <- data.frame(
  name = "Québec",
  geometry = quebec_centroid$geometry
) %>%
  st_as_sf()

# Create inset map
p_inset <- ggplot() +
  geom_sf(data = quebec, fill = "grey90", color = "black", linewidth = 0.3) +
  geom_sf(data = study_area_box, fill = "red", color = "red", alpha = 0.7, linewidth = 0.8) +
  geom_sf_text(data = quebec_label, aes(label = name),
               size = 3.5, fontface = "bold", color = "black") +
  theme_void()


# -----------------------------------------------------------------------------
# 6. COMBINE MAIN MAP WITH INSET
# -----------------------------------------------------------------------------

# Combine main map with inset in top left corner
p_combined <- ggdraw(p_map) +
  draw_plot(p_inset,
            x = 0.1, y = 0.6,  # Position in top left
            width = 0.3, height = 0.3)  # Size of inset

print(p_combined)

# -----------------------------------------------------------------------------
# 7. SAVE OUTPUT
# -----------------------------------------------------------------------------

# Create output directory if it doesn't exist
dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)

# Save the combined map
ggsave("output/figures/fig1_location_map.png",
       p_combined, width = 6, height = 6, dpi = 300)

cat("\n✓ Map saved to output/figures/fig1_location_map.png\n")
cat("\n=== SITE LOCATION MAP COMPLETE ===\n")
