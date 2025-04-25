library(ggplot2)
library(gganimate)

# Parameters
n_frames <- 300  # More frames for smooth animation
word <- "Searching..."
box_size <- 10  # Size of the plot (you can change this)
radius <- 3    # Radius of the rotation

# Create a data frame for the animation
df <- data.frame(
  frame = 1:n_frames,
  angle = seq(0, 2 * pi, length.out = n_frames),  # angle for rotation
  label = word
)

# Calculate x, y positions based on the angle
df$x <- 5 + radius * cos(df$angle)  # Circular x-coordinate
df$y <- 5 + radius * sin(df$angle)  # Circular y-coordinate

# Generate color gradient for a dynamic effect
df$color <- scales::hue_pal()(n_frames)  # A smooth color gradient

# Create the plot
p <- ggplot(df, aes(x, y, label = label, color = color)) +
  geom_text(size = 14, fontface = "bold") +
  coord_fixed(xlim = c(0, box_size), ylim = c(0, box_size), expand = FALSE) +
  theme_void() +
  theme(panel.border = element_rect(color = "black", fill = NA, size = 2)) +
  transition_time(frame) +
  ease_aes('linear')

# Render the animation
animate(p, fps = 20, width = 400, height = 400, renderer = gifski_renderer())