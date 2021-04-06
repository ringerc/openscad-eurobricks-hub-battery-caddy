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

front_height_total = 12.7 + 12.9;
front_width_total = 29.0;


clip_inset = 6.0;
clip_width = 3.5;
// Should be about 10mm between the clips
clip_gap = front_width_total - 2*(clip_inset*clip_width);
clip_height = 3.0;
// Gap between clip slide and notch
clip_to_notch_height = 1.0;
// Notch starts at +4mm, goes to +6mm, is same width as clip
notch_height = 2.0;

key_ridge_width = 1;
key_ridge_depth = 1;

key_ridge_front_height = 9; /* TODO measure */
key_ridge_front_zoff = 4; /* TODO measure */
key_ridge_front_yoff = -4; /* TODO measure */

key_ridge_back_height = 12; /* TODO measure */

contact_width = 4; /* TODO measure */
contact_height = 6; /* TODO measure */
contact_depth = 2; /* TODO measure */

contact_positive_yoff = 0; /* TODO measure */

contact_negative_yoff = -8; /* TODO measure */
contact_negative_zoff = 5; /* TODO measure */

E=0.001;

module AAA_cell() {
        rotate([0,90,0])
        cylinder(
            h=AAA_battery_length,
            d=AAA_battery_diameter);
};

all_batteries = ["t","b","bl","br","tl","tr"];

module batteries(which=all_batteries)
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

module key_ridge(h) {
    cube([key_ridge_width, key_ridge_depth, h]);
}

module contact() {
    cube([contact_depth, contact_width, contact_height], center=true);
}

module end_plate() {
    union() {
        intersection() {
            translate([-1,0,-2])
            {
                hull() batteries(which=["bl","tl","br","b"]);
                hull() batteries(which=["br","tr","bl","b"]);
                batteries(which=["t"]);
            }

            /* main body */
            let(
                pack_cube_h = 2 * AAA_battery_diameter + pack_battery_height_gap
            )
            cube([
                    1,
                    front_width_total,
                    front_height_total
                ],
                center=true
            );
        };
    }
}
        
/* Show batteries */
%translate([0,0,-2]) batteries();

union()
{
    difference()
    {
        end_plate();
        

    // +ve contact (centre)
    translate([
        0,
        contact_positive_yoff,
        front_height_total/2 - contact_height/2+E
    ])
    contact();
    
    // -ve contact (right)
    translate([
        0,
        contact_negative_yoff,
        contact_negative_zoff
    ])
    contact();
    }
    
    // Front key ridge
    translate([-1.5-E,key_ridge_front_yoff,key_ridge_front_zoff])
    key_ridge(key_ridge_front_height);
    
}