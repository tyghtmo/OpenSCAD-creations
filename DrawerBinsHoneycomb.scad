// Customizable bin generator with rounded edges and honeycomb cutouts

// Editable parameters
length = 100;      // Length of the bin
width = 80;        // Width of the bin
height = 50;       // Height of the bin
thickness = 3;     // Wall and bottom thickness
corner_radius = 5; // Radius for rounded edges

// Honeycomb parameters
honeycomb_cell_radius = 5; // Radius of the hexagon cell (center to vertex)
honeycomb_inset = 5;       // Inset distance from edges for the honeycomb pattern
honeycomb_wall_thickness = 1.5; // Desired thickness of the material between cutouts

// Helper module for a single hexagon
module hexagon(r) {
    rotate([0, 0, 30]) // Rotate the base hexagon by 30 degrees
    circle(r = r, $fn = 6);
}

// Helper module for the honeycomb pattern cutout
// Creates an extruded pattern to be subtracted
module honeycomb_cutout(pattern_length, pattern_height, cell_r, wall_thickness, cutout_thickness) {
    // NOTE: The internal logic for step_x, step_y, num_cols, num_rows, 
    // x_pos, y_pos, and the loops remain the same.
    // The change in the hexagon() module automatically handles the orientation.
    
    hex_h = 2 * cell_r; // Height of hexagon (vertex to vertex) - Used for spacing calc
    hex_w = sqrt(3) * cell_r; // Width of hexagon (flat side to flat side) - Used for spacing calc

    // Calculate step distance between hexagon centers including wall thickness
    // These calculations are based on the non-rotated hexagon dimensions but still work for tiling centers
    step_x = hex_w + wall_thickness * sqrt(3); // Horizontal distance center-to-center
    step_y = 3/2 * cell_r + wall_thickness * sqrt(3)/2; // Vertical distance between rows center-to-center

    // Calculate number of rows and columns needed to cover the area, considering spacing
    // Add buffer (+2) to ensure pattern extends slightly beyond the crop area
    num_cols = ceil(pattern_length / step_x) + 2; 
    num_rows = ceil(pattern_height / step_y) + 2; 

    // Center the pattern generation area
    translate([-pattern_length/2, -pattern_height/2, 0]) {
        intersection() {
             // Crop the pattern to the desired size
            cube([pattern_length, pattern_height, cutout_thickness], center=true);
            
            // Generate the grid using calculated step distances
            // Iterate over a slightly larger grid area before cropping
            for (row = [-floor(num_rows/2) : floor(num_rows/2)]) {
                for (col = [-floor(num_cols/2) : floor(num_cols/2)]) {
                    // Calculate position with stagger based on step distances
                    x_pos = col * step_x + (abs(row) % 2 == 1 ? step_x / 2 : 0); // Stagger odd rows
                    y_pos = row * step_y;
                    
                    translate([x_pos, y_pos, 0]) {
                         linear_extrude(height = cutout_thickness, center = true) {
                            hexagon(cell_r); // Calls the now-rotated hexagon module
                        }
                    }
                }
            }
        }
    }
}

module rounded_bin_honeycomb() {
    // Calculate initial dimensions for the honeycomb pattern areas
    _side_pattern_length = length - 2 * honeycomb_inset - 2 * corner_radius;
    _side_pattern_height = height - 2 * honeycomb_inset - thickness; // Inset from top and bottom edge
    _front_pattern_length = width - 2 * honeycomb_inset - 2 * corner_radius;
    
    // Ensure pattern dimensions are positive using the initial calculations
    side_pattern_length = max(0, _side_pattern_length);
    side_pattern_height = max(0, _side_pattern_height);
    front_pattern_length = max(0, _front_pattern_length);
    
    // Thickness for the cutout pattern (should be larger than wall thickness)
    cutout_depth = thickness * 2; 

    difference() {
        // Base rounded bin
        rounded_bin(); 

        // Subtract honeycomb patterns from sides
        
        // Front side
        if (front_pattern_length > 0 && side_pattern_height > 0) {
            translate([0, (width/2 - thickness/2), height/2]) 
            rotate([90, 0, 0]) 
            honeycomb_cutout(front_pattern_length, side_pattern_height, honeycomb_cell_radius, honeycomb_wall_thickness, cutout_depth); // Pass wall thickness
        }

        // Back side
        if (front_pattern_length > 0 && side_pattern_height > 0) {
            translate([0, -(width/2 - thickness/2), height/2]) 
            rotate([90, 0, 0]) 
            honeycomb_cutout(front_pattern_length, side_pattern_height, honeycomb_cell_radius, honeycomb_wall_thickness, cutout_depth); // Pass wall thickness
        }

        // Left side
        if (side_pattern_length > 0 && side_pattern_height > 0) {
            translate([-(length/2 - thickness/2), 0, height/2]) 
            rotate([90, 0, 90]) 
            honeycomb_cutout(side_pattern_length, side_pattern_height, honeycomb_cell_radius, honeycomb_wall_thickness, cutout_depth); // Pass wall thickness
        }
        
        // Right side
        if (side_pattern_length > 0 && side_pattern_height > 0) {
            translate([(length/2 - thickness/2), 0, height/2]) 
            rotate([90, 0, 90]) 
            honeycomb_cutout(side_pattern_length, side_pattern_height, honeycomb_cell_radius, honeycomb_wall_thickness, cutout_depth); // Pass wall thickness
        }
    }
}

// Render the honeycomb bin
// Need to define or include the original rounded_bin module first
module rounded_bin() { // Definition from DrawerBins.scad for completeness if not using include
    intersection()
    {
        difference() {
            // Outer shell with rounded corners
            minkowski() {
                cube([length - 2 * corner_radius, width - 2 * corner_radius, height], center = true);
                sphere(corner_radius);
            }
            // Inner shell with rounded corners (to create the hollow bin)
            translate([0, 0, thickness]) {
                minkowski() {
                    cube([length - 2 * corner_radius - 2 * thickness, width - 2 * corner_radius - 2 * thickness, height - thickness], center = true);
                    sphere(corner_radius);
                }
            }
        }
        // Ensure bottom is flat and bin is cut at the correct height
        translate([0, 0, -1 * (height/2 - corner_radius)]) { // Adjusted translation for centering
                cube([length + 2*corner_radius, width + 2*corner_radius, height], center = true); // Make cube slightly larger to ensure clean cut
            }
    }
}

// Center the final bin for rendering
// Note: The base rounded_bin is already centered at [0,0,0] before the final translate
// Adjust the final translate to place the bottom at Z=0
translate([0, 0, thickness/2]) // Adjust Z based on bottom thickness
rounded_bin_honeycomb();
