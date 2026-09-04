// Parametric LEGO Train Wheel, modeled after the official wheel that ships
// on the 9V/PF train motor: "Train Wheel for RC Train w Technic Axle Hole
// and Rubber Ring" (BrickLink 55423c01 / LDraw u9241+u9242).
// Profile (flange/riser/tread diameters, axle hole shape) measured directly
// off a reference scan of the real part (55423.stl): wide tapered flange,
// stepped riser, crowned+grooved tread, 12-spoke closed hub face.
// All measurements in millimeters (mm)

// Resolution
$fn = 100;

// Overall depth
wheel_width = 4.5;

// Flange: a short straight full-diameter rim edge (like the real part's
// rail-contact edge), then a shallow cone down to the riser
flange_dia            = 24.0;
flange_straight_height = 0.7;  // straight section at full flange_dia, from z=0
flange_height          = 2.0;  // total flange section height (straight + taper)

// Riser: cylindrical shoulder between flange and tread
riser_dia    = 17.0;
riser_height = 0.6;

// Tread: crowned profile with a dip (rubber-band groove) near the riser
// side and a slight crown bulge further out, tapering back in at the top
tread_height    = 1.4;
groove_dia      = 16.7;
groove_z_frac   = 0.35;  // fraction of tread_height where the groove sits
crown_dia       = 18.3;
crown_z_frac    = 0.78;  // fraction of tread_height where the crown peak sits
tread_end_dia   = 17.0;

// Hub face (closed disc with recessed spoke channel — only the axle hole
// goes all the way through)
//hub_dia       = 6.0;    // inner boundary of the recessed channel
hub_dia       = 7.0;    // inner boundary of the recessed channel
hub_rim_wall  = 1.5;    // solid wall width left at the outer rim
spoke_count   = 12;     // matches the real part
spoke_rib_deg = 8;      // angular width of each raised spoke rib
pocket_floor  = -0.3;    // material left at the bottom of the recessed channel

// Technic cross-axle hole (fits the train motor's output shaft), measured
// off the reference part: ~5.2mm tip-to-tip, ~2.2mm arm width
axle_span = 5.2;
axle_arm  = 2.2;  // adjust both for your printer tolerance

eps = 0.05;  // overlap between stacked solids, avoids coplanar z-fighting

riser_end_z = flange_height + riser_height;
tread_end_z = riser_end_z + tread_height;
hub_section_height = wheel_width - tread_end_z;
rim_ring_dia = tread_end_dia;
channel_outer_dia = rim_ring_dia - 2 * hub_rim_wall;

extender_height = 5;

module axle_hole() {
    /*h = wheel_width + 2;
    for (a = [0, 90])
        rotate([0, 0, a])
            translate([-axle_span / 2, -axle_arm / 2, -1])
                cube([axle_span, axle_arm, h]);*/
    
    // tt motor axle
    h = wheel_width + 2 + extender_height;
    axle_heigth = 3.7 + 0.02; // 0.02 tolerance
    axle_width = 5.3;
    translate([-axle_width / 2, -axle_heigth / 2, -1 - extender_height])
        cube([axle_width, axle_heigth, h]);
}

function wedge_pts(a0, span, r, steps = 8) =
    concat([[0, 0]], [for (i = [0 : steps]) [r * cos(a0 + span * i / steps), r * sin(a0 + span * i / steps)]]);

module pocket_2d(r_in, r_out, a0, span) {
    intersection() {
        difference() {
            circle(r = r_out);
            circle(r = r_in);
        }
        polygon(wedge_pts(a0, span, r_out + 1));
    }
}

// Blind recesses cut into the hub face between the spoke ribs — visual
// detail only, never breaking through to the flange side.
module spoke_pockets() {
    // clamp so at least 0.1mm of floor always remains, even if pocket_floor
    // is larger than the currently configured hub_section_height
    effective_floor = min(pocket_floor, hub_section_height - 0.1);
    depth = hub_section_height - effective_floor;
    pocket_span = 360 / spoke_count - spoke_rib_deg;
    for (i = [0 : spoke_count - 1]) {
        a0 = i * 360 / spoke_count + spoke_rib_deg / 2;
        // cut down from the true outward face (wheel_width), not from
        // tread_end_z, so this stays correct even if flange/riser/tread
        // heights change and shrink or grow hub_section_height
        translate([0, 0, wheel_width - depth])
            linear_extrude(height = depth + 0.5)
                // outer radius stops just short of the disc's own edge
                // so the cut doesn't sit exactly on the model's real outer surface
                pocket_2d(hub_dia / 2, channel_outer_dia / 2 - 0.2, a0, pocket_span);
    }
}

// Axisymmetric flange + riser + crowned/grooved tread body
module wheel_body() {
    profile = [
        [0, 0],
        [flange_dia / 2, 0],
        [flange_dia / 2, flange_straight_height],
        [riser_dia / 2, flange_height],
        [riser_dia / 2, riser_end_z],
        [groove_dia / 2, riser_end_z + tread_height * groove_z_frac],
        [crown_dia / 2, riser_end_z + tread_height * crown_z_frac],
        [tread_end_dia / 2, tread_end_z],
        [0, tread_end_z],
    ];
    rotate_extrude()
        polygon(profile);
}

module lego_train_wheel() {
    difference() {
        union() {
            wheel_body();

            // Closed hub face — solid disc, overlapped into the tread body
            translate([0, 0, tread_end_z - eps])
                cylinder(d = rim_ring_dia, h = hub_section_height + eps);
            
            translate([0, 0, -extender_height])
                cylinder(extender_height, 4, 4);
        }

        axle_hole();
        spoke_pockets();
    }
}

lego_train_wheel();
