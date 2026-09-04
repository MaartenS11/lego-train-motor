lego_block_height = 9.6;
lego_stud_spacing = 8.0;
lego_plate_heigth = 3.2;
lego_stud_dia = 4.8 + 0.2;
lego_stud_height = 1.8;
function lego_block_size(size) = size * lego_stud_spacing - 0.2;

// Grid of LEGO studs on an 8mm pitch, sized nx x ny studs, hanging below
// z=0 (overlapping it by eps) so it unions cleanly onto the bottom face
// of a block that starts at z=0.
module lego_stud_grid(nx, ny) {
    for (ix = [0 : nx - 1])
        for (iy = [0 : ny - 1])
            translate([ix * lego_stud_spacing + lego_stud_spacing / 2,
                        iy * lego_stud_spacing + lego_stud_spacing / 2,
                        -lego_stud_height + eps])
                cylinder(h = lego_stud_height, d = lego_stud_dia, $fn = 30);
}

lego_hole_tolerance = 0.3;

module lego_hole() {
    translate([7.8, 0, 0])
    rotate([0,-90,0]) 
    //cylinder(8, 2.4, 2.4, $fn=20);
    cylinder(8, 2.4 + lego_hole_tolerance, 2.4 + lego_hole_tolerance, $fn=32);
    
    translate([0.8, 0, 0])
    rotate([0,-90,0]) 
    //cylinder(1, 3.1, 3.1, $fn=20);
    cylinder(1, 3.1 + lego_hole_tolerance, 3.1 + lego_hole_tolerance, $fn=32);
    
    translate([7.8, 0, 0])
    rotate([0,-90,0]) 
    //cylinder(1, 3.1, 3.1, $fn=20);
    cylinder(0.8, 3.1 + lego_hole_tolerance, 3.1 + lego_hole_tolerance, $fn=32);
};

module lego_hole_long(hole_length) {
    translate([hole_length, 0, 0])
    rotate([0,-90,0]) 
    //cylinder(8, 2.4, 2.4, $fn=20);
    cylinder(hole_length, 2.4 + lego_hole_tolerance, 2.4 + lego_hole_tolerance, $fn=32);
    
    translate([0.8, 0, 0])
    rotate([0,-90,0]) 
    //cylinder(1, 3.1, 3.1, $fn=20);
    cylinder(1, 3.1 + lego_hole_tolerance, 3.1 + lego_hole_tolerance, $fn=32);
};

motor_width = 19 + 3*2; // 25 maybe we could go 1mm lower but trying to give it some space so it is not super tight
wire_spacing = 3;
motor_length = 65 + 1 + wire_spacing;
motor_wire_gap = 5;
axle_offset = 11;

motor_start_offset = 7 - 2.2; // So the holes align with the lego studs
eps = 0.01;
tolerance = 0.2;

difference() {
    case_width = lego_block_size(4);
    case_height = lego_block_height * 2;

    union() {
        cube([case_width, lego_block_size(11), case_height]);
        
        // studs
        lego_stud_grid(4, 8);
        translate([0,lego_stud_spacing*9,0])
        lego_stud_grid(4, 2);
    }

    // Thing sticking out at the front of the motor
    front_stick_length = 5 + 1 + tolerance; // 1 mm of extra spacing so the motor can slide a little forward if needed
    translate([case_width/2-3/2,motor_start_offset-front_stick_length+eps,lego_plate_heigth + axle_offset - front_stick_length/2])
    cube([3, front_stick_length, case_height]);
    
    // Motor itself
    translate([case_width/2-motor_width/2,motor_start_offset,lego_plate_heigth])
    cube([motor_width,motor_length,motor_width]);
    
    // Wire hole
    translate([case_width/2-motor_width/2,motor_start_offset + motor_length-motor_wire_gap-3.4,-eps])
    cube([motor_width,motor_wire_gap,lego_plate_heigth+eps*2]);
    
    // Motor axle hole
    hole_r = 4 + 1 + tolerance;
    translate([case_width + 1,motor_start_offset + axle_offset,lego_plate_heigth + axle_offset]) {
        rotate([0, -90, 0])
        cylinder(case_width + 2, hole_r, hole_r, $fn=32);
    }
    translate([-1, motor_start_offset + axle_offset - hole_r,lego_plate_heigth + axle_offset])
    cube([case_width + 2, hole_r * 2, case_height]);
    
    // Motor mounting holes
    translate([case_width + 1,motor_start_offset + axle_offset + 20.1,lego_plate_heigth + axle_offset - 8.75])
    rotate([0, -90, 0])
    cylinder(case_width + 2, 1.5 + tolerance, 1.5 + tolerance, $fn=20);
    
    // Lego axle + extra technic hole
    translate([0,motor_start_offset + axle_offset + lego_block_size(8),lego_plate_heigth + axle_offset]) {
        lego_hole_long(case_width/2+eps);
        
        translate([case_width,0,0])
        rotate([0,0,180])
        lego_hole_long(case_width/2+eps);
        
        translate([0,0,-lego_stud_spacing]) {
            lego_hole();
            
            translate([case_width,0,0])
            rotate([0,0,180])
            lego_hole();
        }
    }
}