// Customizable bin generator with rounded edges and honeycomb cutouts
use <DrawerBins.scad>
use <Honeycomb.scad>

// Editable parameters
length = 100;      // Length of the bin
width = 400;        // Width of the bin
height = 60;       // Height of the bin
thickness = 5;     // Wall and bottom thickness
corner_radius = 5; // Radius for rounded edges

// Honeycomb parameters
honeycomb_offset = 3;
honeycomb_cell_radius = 8; // Radius of the hexagon cell (center to vertex)      
honeycomb_spacing = 1.2; 

module rounded_bin_honeycomb()
{
    honeycomb_length = length - (2 * (honeycomb_offset + corner_radius));
    honeycomb_height = height - (2 * (honeycomb_offset + (corner_radius/1.5)));
    honeycomb_width = width - (2 * (honeycomb_offset + corner_radius));
    
    difference(){
        rounded_bin(length, width, height, thickness, corner_radius);
        
        rotate([90,0,0])
        translate([honeycomb_length / 2, (honeycomb_height / 2) - (corner_radius/2), 0])
        honeycomb_pattern(honeycomb_length, honeycomb_height, honeycomb_cell_radius, honeycomb_spacing, width);

        rotate([90, 0, 90])
        translate([honeycomb_width/2, (honeycomb_height / 2) - (corner_radius/2), 0])
        honeycomb_pattern(honeycomb_width, honeycomb_height, honeycomb_cell_radius, honeycomb_spacing, length);
    }
}

rounded_bin_honeycomb();
