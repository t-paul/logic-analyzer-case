// Case for logic analyzer board (Cypress FX2 dev board)
// https://www.amazon.de/dp/B07DJ4L53F
//
// Torsten Paul <Torsten.Paul@gmx.de>, October 2023
// CC BY-SA 4.0
// https://creativecommons.org/licenses/by-sa/4.0/

/* [Part Selection] */
selection = 0; // [ 0:Assembly, 1:Base, 2:Cap ]

eps = 0.01;
wall = 2;
tolerance = 0.3;

pcb_thickness = 1.6;

bottom_thickness = 2 * wall;
bottom_screw_dia = 3 + 2 * tolerance;
bottom_screw_head_h = 2;
bottom_screw_head_dia = 6;
bottom_pillar_h = 3;
bottom_pillar_dia = bottom_screw_dia + 2 * wall;

width = 41;
length = 57;
height = 10 + bottom_pillar_h + pcb_thickness;
screw_offset = 3.5;

top_usb_offset = 2.5;
top_pillar_h = height - wall - pcb_thickness - 1;

usb_height = 9; // cutout height
usb_width = 13; // cutout width
usb_h = 4.2; // height of the usb connector itself

switch_x_offset = 4.5;
switch_y_offset =10.5;
switch_size = 6;

pins_width = 12;
pins_length = 30;
pins_h = 6;
pins_y_offset = 5; // offset from middle of the pcb

parts = [
    [ "assembly", [0, 0,  0 ], [   0, 0, 0], undef],
    [ "bottom",   [0, 0,  0 ], [   0, 0, 0], undef],
    [ "top",      [0, 0, 40 ], [ 180, 0, 0], undef]
];

module screw_hole(d = 3, o = 1) {
	polygon([for (a = [0:359]) (d/2 + o * sin(a * 5)) * [ -sin(a), cos(a) ]]);
}

module screw_pos() {
	for (x = [screw_offset, length - screw_offset], y = [-1, 1])
		translate([x, y * (width/2 - screw_offset)])
			children();
}

module top() {
	difference() {
		union() {
			// top casing
			linear_extrude(wall, convexity = 3)
				translate([0, -width/2])
					offset(3 * wall)
						offset(-wall)
							square([length, width]);
			// side walls
			linear_extrude(height, convexity = 3)
				translate([0, -width/2])
					difference() {
						offset(3 * wall)
							offset(-wall)
								square([length, width]);
						offset(2 * wall)
							offset(-wall)
								square([length, width]);
					}
			// mounting pillars
			screw_pos()
				cylinder(h = top_pillar_h, d = bottom_screw_dia + 3);
		}
		// usb cutout
		translate([-3 * wall, top_usb_offset, height - bottom_pillar_h - pcb_thickness - usb_h / 2])
			rotate([0, 90, 0])
				linear_extrude(5 * wall, convexity = 3)
					offset(2)
						offset(-2)
							square([usb_height, usb_width], center = true);
		// screw holes
		screw_pos()
			translate([0, 0, top_pillar_h + wall])
				mirror([0, 0, 1])
					linear_extrude(top_pillar_h, scale = 0.8, convexity = 3)
						screw_hole(bottom_screw_dia, tolerance);
		// switch cutout
		translate([switch_x_offset, -width / 2 + switch_y_offset, 0])
			linear_extrude(10 * wall, center = true)
				offset(1)
					offset(-1)
						square(switch_size, center = true);
		// pins cutout
		translate([length / 2 + pins_y_offset, -width / 2, 0])
			linear_extrude(2 * pins_h, center = true)
				offset(1)
					offset(-1)
						square([pins_length, 2 * pins_width], center = true);
		translate([length / 2 + pins_y_offset, width / 2, 0])
			linear_extrude(2 * pins_h, center = true)
				offset(1)
					offset(-1)
						square([pins_length, 2 * pins_width], center = true);
	}
}

module bottom() {
	difference() {
		union() {
			linear_extrude(bottom_thickness)
				translate([0, -width/2])
					offset(3 * wall)
						offset(-wall)
							square([length, width]);
			screw_pos()
				cylinder(h = bottom_thickness + bottom_pillar_h, d = bottom_pillar_dia);
		}
		screw_pos()
			cylinder(h = 2 * bottom_screw_head_h, d = bottom_screw_head_dia, center = true);
		screw_pos()
			cylinder(h = 10 * wall, d = bottom_screw_dia, center = true);
	}
}

module part_select() {
    for (idx = [0:1:$children-1]) {
        if (selection == 0) {
            col = parts[idx][3];
            translate(parts[idx][1])
                rotate(parts[idx][2])
                    if (is_undef(col))
                        children(idx);
                    else
                        color(col[0], col[1])
                            children(idx);
        } else {
            if (selection == idx)
                children(idx);
        }
    }
}

part_select() {
	union() {}
	bottom();
    top();
}

$fa = 2; $fs = 0.2;
