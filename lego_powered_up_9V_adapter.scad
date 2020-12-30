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

module AAA_cell() {
        rotate([0,90,0])
        cylinder(
            h=AAA_battery_length,
            d=AAA_battery_diameter);
};

module batteries()
{

    let(batt_space = AAA_battery_diameter + battery_diameter_tolerance)
    for (pack_zoff = [0, AAA_battery_diameter + pack_battery_height_gap])
    translate([0,0,pack_zoff])
    {
        AAA_cell();

        for (lr=[-1,1])
        translate([0,
            lr*cos(-30)*batt_space,
            sin(-30)*batt_space])
        AAA_cell();
    }
}

//translate([0,0,-2]) batteries();

hull()
intersection() {
    translate([-1,0,-2])
    batteries();

    cube([
            1,
            front_width_total,
            front_height_total
        ],
        center=true
    );
}