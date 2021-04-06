/*
 * 9V cell adapter for lego powered up trains. Front has contacts.
 */
 
 /*
  * It's made of 6xAAAs.
  * 
  * The casing has about 0.5mm tolerance around the AAA diameter.
  */
AAA_battery_diameter = 10.5;
AAA_battery_length = 44.5;

// Space caddy allows between battery and edge of spacer, approx
battery_diameter_tolerance = 0.5;
// Z-gap between batteries in the layers
pack_battery_height_gap = 1;

end_wall_thickness = 1;
base_thickness = 1;
side_wall_thickness = 1;


// The entire control box case exterior is 63.8 long

//base_length_outside_to_outside = AAA_battery_length + end_wall_thickness * 2;
base_length_outside_to_outside = 51.8;

front_height_total = 25.6;
front_width_total = 29.0;

/* Back has a cutout lower than front, seems to be part of the keying */
back_height_total = 24.1;
back_width_total = front_width_total;

clip_inset = 6.0;
clip_width = 3.5;
// Should be about 10mm between the clips
clip_gap = front_width_total - 2*(clip_inset*clip_width);
clip_height = 3.0;
// Gap between clip slide and notch
clip_to_notch_height = 1.0;
// How deep clip notch is. This determines the height of the notches too. They're a bit less than 2*clip_depth.
clip_depth = 0.8;
// Notch starts at +4mm, goes to +6mm, is same width as clip
notch_height = 2.0;


/* Key ridge on front is actually 12.73 high but falls on a curve. So we'll make the key shorter. */
key_ridge_front_height = 11.0; /* TODO measure */
key_ridge_front_zoff = 1;
key_ridge_front_width = 1;
key_ridge_front_depth = 0.9;
/* Its inner (left) edge is 12 - key_ridge_depth from the right edge. This offset is key ridge centre from box centre. */
key_ridge_front_yoff = -(front_width_total/2 - (12.0  - key_ridge_front_depth/2));

/* back ridges are slightly bigger */
key_ridge_back_width = 1.2;
key_ridge_back_depth = 1.2;
/* The real one follows the curve of the battery and is 14.8 high but we can just make it a bit shorter */
key_ridge_back_height = 11.0;
/* The inside of each ridge is 8mm from the corresponding edge */
key_ridge_back_yoff = back_width_total / 2 - key_ridge_back_width/2 - 8;
key_ridge_back_zoff = -2;

contact_width = 4.0;
contact_height = 7.5;
contact_depth = 2;

contact_positive_yoff = 0;

/* Right edge of contact cutout is 4.65 from right outside wall */
contact_negative_yoff = -(front_width_total/2 - contact_width/2) + 4.65;

contact_negative_zoff = 6; /* approx is ok here */

battery_standoff_feet_height = 7;
battery_standoff_feet_d = 2;

E=0.001;

/* Preview using AAA or 9V */
//preview_with_aaa = true;
preview_with_aaa = false;

use <uploads_f1_eb_f2_54_dd_Batteries.scad>;

module AAA_cell() {
    rotate([0,90,0])
    AAA();
};

all_batteries = ["t","b","bl","br","tl","tr"];

module batteries_AAA(which=all_batteries)
{
    let(batt_space = AAA_battery_diameter + battery_diameter_tolerance)
    for (pack_zoff = [0, AAA_battery_diameter + pack_battery_height_gap])
    translate([0,0,pack_zoff])
    {
        let(batt_name = (pack_zoff == 0 ? "b" : "t"))
        {
            //echo(pack_zoff, batt_name);
            
            if ([ for (w = which) if (w == batt_name) w])
            AAA_cell();
        }

        for (lr=[-1,1])
        let(batt_name = str((pack_zoff == 0 ? "b" : "t"), (lr == -1 ? "l" : "r")))
        {
            //echo(pack_zoff, lr, batt_name);
            
            if ([ for (w = which) if (w == batt_name) w])
            translate([0,
                lr*cos(-30)*batt_space,
                sin(-30)*batt_space])
            AAA_cell();
        }
    }
}

module batteries_9V() {
    translate([base_length_outside_to_outside,0,0])
    rotate([180,0,0])
    translate([-5,-11.5,8])
    rotate([0,-90,0])
    rotate([0,0,90])
    9V();
}

module key_ridge_front() {
    cube([key_ridge_front_width, key_ridge_front_depth, key_ridge_front_height]);
}

module key_ridge_back() {
    cube([key_ridge_back_width, key_ridge_back_depth, key_ridge_back_height]);
}


module contact() {
    cube([contact_depth, contact_width, contact_height], center=true);
}

module end_plate(end_plate_height, z_offset=0) {
    let(
        pack_cube_h = 2 * AAA_battery_diameter + pack_battery_height_gap
    )
    translate([end_wall_thickness*1.5+E,0,0])
    difference() {
        union() {
            intersection() {
                translate([-end_wall_thickness,0,-2])
                {
                    hull()
                    batteries_AAA(which=[ for (w = all_batteries) if (w != "t") w ]);
                    batteries_AAA(which=["t"]);
                }

                /* main body; requires an offset for rear */
                translate([-end_wall_thickness/2,0,z_offset])
                cube([
                        end_wall_thickness,
                        front_width_total,
                        end_plate_height
                    ],
                    center=true
                );
            };
            
            /* Square off bottom */
            translate([
                -end_wall_thickness,
                -front_width_total/2,
                -end_plate_height/2 + z_offset
            ])
            cube([1, front_width_total, AAA_battery_diameter], center=false);
        };
        
        /* clip notches */
        translate([-end_wall_thickness-3*E, 0, 0])
        {
            let(
                clip_curve_adj = 0.3,
                clip_cyl_r = clip_depth + clip_curve_adj
            )
            for (lr = [-1,1])
            translate([0, lr * (clip_gap/2), clip_inset])
            translate([0, 0,
                    -end_plate_height + clip_inset + z_offset])
            {
                translate([-0.3,0,0])
                translate([0,clip_width/2,-clip_cyl_r+clip_inset])
                rotate([90,0,0])
                cylinder(r=clip_cyl_r,h=clip_width,$fs=0.3);
                
                rotate([0,-8,0])
                translate([0,-clip_width/2, -clip_height])
                cube([clip_depth, clip_width, clip_height*2]);
            }
        }
    }
}

module front_plate() {
    translate([-end_wall_thickness/2,0,0])
    union()
    {
        difference()
        {
            end_plate(front_height_total);
             
            // +ve contact (centre)
            translate([
                end_wall_thickness,
                contact_positive_yoff,
                front_height_total/2 - contact_height/2 + 2*E
            ])
            contact();

            // -ve contact (right)
            translate([
                end_wall_thickness,
                contact_negative_yoff,
                contact_negative_zoff
            ])
            contact();
        }
        
        // Front key ridge
        translate([
            - key_ridge_front_width/2 + E,
            key_ridge_front_yoff - key_ridge_front_depth/2,
            key_ridge_front_zoff
        ])
        key_ridge_front();
    }
}

module back_plate() {
    translate([end_wall_thickness/2,0,0])
    union()
    {
        rotate([0,0,180])
        end_plate(back_height_total, z_offset = (back_height_total-front_height_total)/2);
        
        // Back key ridge
        for (lr=[-1,1])
        translate([
            -end_wall_thickness/2-E,
            (key_ridge_back_yoff + key_ridge_back_depth) * lr,
            key_ridge_back_zoff
        ])
        translate([0,-key_ridge_back_depth/2,0])
        key_ridge_back();
    }
}

module base_plate() {
    translate([end_wall_thickness+2*E, -front_width_total/2, 0])
    cube([
        base_length_outside_to_outside - 2*end_wall_thickness - 8*E,
        front_width_total-2*E,
        base_thickness
    ]);
}

module sidewall() {
    translate([end_wall_thickness, -side_wall_thickness/2, 0])
    cube([
        base_length_outside_to_outside - 2*end_wall_thickness -2*E,
        side_wall_thickness,
        front_height_total/2
    ]);
}

union() {
    /* Front end plate */
    front_plate();
    
    /* Rear end plate */
    translate([base_length_outside_to_outside, 0, 0])
    back_plate();
    
    /* Base */
    translate([0,0,-front_height_total/2])
    base_plate();
    
    /* Side walls */
    for(lr = [-1, 1])
    translate([
        0,
        (front_width_total/2 - side_wall_thickness/2) * lr,
        -front_height_total/2
    ])
    sidewall();
    
    /* Feet to raise 9v battery up, since we want it in the top */
    for (lr = [-1,0,1], fb = [0,0.5,1])
    translate([
        base_length_outside_to_outside*0.8 * fb,
        front_width_total/3 * lr,
        0
    ])
    translate([
        base_length_outside_to_outside*0.1,
        0,
        -front_height_total/2 + base_thickness - E
    ])
    cylinder(h=battery_standoff_feet_height, d=battery_standoff_feet_d);
}


/* Show batteries */
%
color("blue",0.2)
translate([
    (base_length_outside_to_outside - AAA_battery_length)/2,
    0,
    -2
])
if (preview_with_aaa) {
    batteries_AAA();
} else {
    translate([0,0,battery_standoff_feet_height])
    batteries_9V();
}