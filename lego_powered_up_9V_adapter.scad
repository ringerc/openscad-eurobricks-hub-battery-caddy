/*
 * 9V cell adapter for lego powered up trains. Front has contacts.
 *
 * IT WORKS!!!!!111!!!
 *
 * Slight corner rounding for printability?
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

end_wall_thickness_front = 3 ;
end_wall_thickness_back = 1;
end_walls_thickness_total = end_wall_thickness_front + end_wall_thickness_back;
base_thickness = 1;
side_wall_thickness = 1;

base_plate_zoff = 5;


// The entire control box case exterior is 63.8 long
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
clip_height = 3;
// Gap between clip slide and notch
clip_to_notch_height = 1.0;
// How deep clip notch is. This determines the height of the notches too. They're a bit less than 2*clip_depth.
clip_depth = 0.5;
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
contact_depth = 4.1;

contact_positive_yoff = 0;

/* Right edge of contact cutout is 4.65 from right outside wall */
contact_negative_yoff = -(front_width_total/2 - contact_width/2) + 4.65;

contact_negative_zoff = 6; /* approx is ok here */

feet_top_d = 1.5;
feet_base_d = 3;

E=0.005;

side_wall_height = front_height_total/2;

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

/* TODO gentle slope in bottom overhang of key items */
module key_ridge_front() {
    cube([key_ridge_front_width, key_ridge_front_depth, key_ridge_front_height]);
}

module key_ridge_back() {
    cube([key_ridge_back_width, key_ridge_back_depth, key_ridge_back_height]);
}


module contact() {
    cube([contact_depth, contact_width, contact_height], center=true);
}

module end_plate(end_plate_height, end_wall_thickness, z_offset=0) {
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
            cube([end_wall_thickness, front_width_total, AAA_battery_diameter], center=false);
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
    translate([-end_wall_thickness_front/2,0,0])
    union()
    {
        difference()
        {
            end_plate(front_height_total, end_wall_thickness_front);
             
            // +ve contact (centre)
            translate([
                end_wall_thickness_front,
                contact_positive_yoff,
                front_height_total/2 - contact_height/2 + 2*E
            ])
            contact();

            // -ve contact (right)
            translate([
                end_wall_thickness_front,
                contact_negative_yoff,
                contact_negative_zoff
            ])
            contact();
        
            // Key to prevent battery insertion upside down.
            // Add a cutout for the +ve contact.
            let(
                batt_key_slot_depth = 1.5,
                positive_terminal_slot_height = front_height_total - base_plate_zoff - base_thickness + E,
                positive_terminal_slot_zoff = 12.6,
                negative_terminal_slot_height = front_height_total - base_plate_zoff - base_thickness + E,
                negative_terminal_slot_zoff = 10.5,
                contact_guide_thickness = 1
            )
            translate([0, 0, 0])
            {   
                /* Slot for +ve battery terminal */
                translate([
                    2*end_wall_thickness_front - batt_key_slot_depth + E,
                    0,
                    base_plate_zoff + base_thickness])
                {
                    translate([
                         0,
                         5.75,
                         - positive_terminal_slot_height/2  + positive_terminal_slot_zoff
                    ])
                    cube([
                        end_wall_thickness_front+3*E,
                        6.2,
                        positive_terminal_slot_height
                    ], center=true);
                    
                    /* Slot for -ve battery terminal */
                    translate([
                         0,
                         -7.5,
                         - negative_terminal_slot_height/2 + negative_terminal_slot_zoff
                    ])
                    cube([
                        end_wall_thickness_front+3*E,
                        9,
                        negative_terminal_slot_height
                    ], center=true);
                    
                    translate([-contact_guide_thickness-0.5,0,0])
                    {
                        /* Slot for +ve contact plate retainer */
                        translate([0,3,-1])
                        difference() {
                            rotate([90-51,0,0])
                            translate([0,0,-3])
                            cube([
                                contact_guide_thickness,
                                6,
                                16
                            ], center=true);
                            
                            /* Crude hack to stop contact slicing into opposite pillar */
                            translate([E,-4,3])
                            cube([contact_guide_thickness+4*E, 5, 5],center=true);
                        }
                        
                        /* Extra slot for +ve contact retainer so contact plate can be inserted downwards, then swiveled into place */
                        translate([0,6.5,-6])
                        cube([contact_guide_thickness, 7, 4],center=true);
                        
                        /* Slot for -ve contact plate retainer */
                        translate([0,-8,-6])
                        cube([
                            contact_guide_thickness,
                            4,
                            9
                        ], center=true);
                    };
                };
            }
        }
        
    }

    // Front key ridge
    translate([
        - key_ridge_front_width + E,
        key_ridge_front_yoff - key_ridge_front_depth/2,
        key_ridge_front_zoff
    ])
    key_ridge_front();
    
    
}

module back_plate() {
    translate([end_wall_thickness_back/2,0,0])
    union()
    {
        rotate([0,0,180])
        end_plate(back_height_total, end_wall_thickness_back, z_offset = (back_height_total-front_height_total)/2);
        
        // Back key ridge
        for (lr=[-1,1])
        translate([
            -end_wall_thickness_back/2-E,
            (key_ridge_back_yoff + key_ridge_back_depth) * lr,
            key_ridge_back_zoff
        ])
        translate([0,-key_ridge_back_depth/2,0])
        key_ridge_back();
    }
}

module base_plate() {
    translate([end_wall_thickness_front+2*E, -front_width_total/2, base_plate_zoff])
    cube([
        base_length_outside_to_outside - end_walls_thickness_total - 8*E,
        front_width_total-2*E,
        base_thickness
    ]);
}

module sidewall(lr) {
    translate([end_wall_thickness_front, -side_wall_thickness/2, 0])
    let(side_wall_length = base_length_outside_to_outside - end_walls_thickness_total)
    union() {
        difference()
        {
            /* Main sidewall */
            cube([
                side_wall_length -2*E,
                side_wall_thickness,
                side_wall_height
            ]);
            
            /* Cut out the bottom */
            translate([side_wall_length/5, -2*E, -E])
            cube([
                3*side_wall_length/5,
                side_wall_thickness+4*E,
                base_plate_zoff
            ]);
        }
        
        /* Reinforcing at the edges of the side cuts so they don't crumple too easily */
        let(w=side_wall_thickness*2)
        for(fb=[0,1])
        translate([fb*(3*side_wall_length/5 + w),0,0])
        translate([side_wall_length/5, -2*E, -E])
        translate([
            -w/2 + w/2*lr - E,
            -w/2*min(lr,0) + 4*E*lr,
            0])
        scale([1,0.5,1])
        rotate([90,0,-90*lr])
        linear_extrude(w)
        polygon(points=[[base_plate_zoff,base_plate_zoff],[0,0],[0,base_plate_zoff]]);
    }
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
    sidewall(lr);
    
    /* supports for rear side wall */
    let(support_height = side_wall_height - base_plate_zoff - base_thickness - 1.5)
    for(lr = [-1, 1])
    translate([
        base_length_outside_to_outside - side_wall_thickness + E,
        lr * (front_width_total - side_wall_thickness)/2,
        -E*2
    ])
    translate([0, side_wall_thickness/2, 0])
    scale([support_height,1,support_height])
    rotate([90,-90,0])
    linear_extrude(side_wall_thickness)
    polygon(points=[[0,0],[0,1],[1,0]]);
    
    /* The right sidewall, with the +ve terminal, needs some spacers to position the battery */
    translate([
        0,
        (front_width_total/2 - side_wall_thickness*2)+E,
        0
    ])
    for (i = [0 : 4])
    translate([
        base_length_outside_to_outside * (0.2 + i*0.2) - end_walls_thickness_total,
        0,
        -side_wall_height + base_plate_zoff - E])
    cube([1,1,side_wall_height - base_plate_zoff]);
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
    translate([0,-1,base_plate_zoff + base_thickness])
    batteries_9V();
}