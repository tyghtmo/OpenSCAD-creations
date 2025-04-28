// Customizable bin generator with rounded edges

// Editable parameters
length = 100;      // Length of the bin
width = 80;        // Width of the bin
height = 50;       // Height of the bin
thickness = 3;     // Wall and bottom thickness
corner_radius = 5; // Radius for rounded edges

module rounded_bin() {
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
        translate([0, 0, -1 * corner_radius]) {
                cube([length, width, height], center = true);
            }
    }
}

// Render the bin
translate([length/2, width/2, height/2 + corner_radius])
rounded_bin();