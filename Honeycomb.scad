// Honeycomb parameters
honeycomb_length = 200;
honeycomb_height = 100;
honeycomb_cell_radius = 5; // Radius of the hexagon cell (center to vertex)
honeycomb_thickness = 5;       
honeycomb_spacing = 2.5; 

module hexagon(r) {
    rotate([0, 0, 30]) // Rotate the base hexagon by 30 degrees
    circle(r = r, $fn = 6);
}

module honeycomb_pattern(pattern_length, pattern_height, cell_r, hex_spacing, thickness) {
    // NOTE: The internal logic for step_x, step_y, num_cols, num_rows, 
    // x_pos, y_pos, and the loops remain the same.
    // The change in the hexagon() module automatically handles the orientation.
    
    hex_h = 2 * cell_r; // Height of hexagon (vertex to vertex) - Used for spacing calc
    hex_w = sqrt(3) * cell_r; // Width of hexagon (flat side to flat side) - Used for spacing calc

    // Calculate step distance between hexagon centers including wall thickness
    // These calculations are based on the non-rotated hexagon dimensions but still work for tiling centers
    step_x = hex_w + hex_spacing * sqrt(3); // Horizontal distance center-to-center
    step_y = 3/2 * cell_r + hex_spacing * sqrt(3)/2; // Vertical distance between rows center-to-center

    // Calculate number of rows and columns needed to cover the area, considering spacing
    // Add buffer (+2) to ensure pattern extends slightly beyond the crop area
    num_cols = ceil(pattern_length / step_x) + 2; 
    num_rows = ceil(pattern_height / step_y) + 2; 

    // Center the pattern generation area
    translate([-pattern_length/2, -pattern_height/2, 0]) {            
            // Generate the grid using calculated step distances
            // Iterate over a slightly larger grid area before cropping
            for (row = [-floor(num_rows/2) : floor(num_rows/2)]) {
                for (col = [-floor(num_cols/2) : floor(num_cols/2)]) {
                    // Calculate position with stagger based on step distances
                    x_pos = col * step_x + (abs(row) % 2 == 1 ? step_x / 2 : 0); // Stagger odd rows
                    y_pos = row * step_y;
                    
                    if (
                        abs(y_pos + cell_r) < abs(pattern_height/2) && 
                        abs(y_pos - cell_r) < abs(pattern_height/2) && 
                        abs(x_pos + cell_r) < abs(pattern_length/2) &&
                        abs(x_pos - cell_r) < abs(pattern_length/2)
                    ){
                    translate([x_pos, y_pos, 0]) {
                         linear_extrude(height = thickness, center = true) {
                            hexagon(cell_r); // Calls the now-rotated hexagon module
                        }
                    }
                }
            }
        }
    }
}

honeycomb_pattern(honeycomb_length, honeycomb_height, honeycomb_cell_radius, honeycomb_spacing, honeycomb_thickness);
