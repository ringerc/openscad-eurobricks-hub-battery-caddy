/*
 * Attempt to design Powered Up-compatible power/data connector.
 */
 
 // Controls to split out the parts
 render_base = 1;
 render_clip = 1;
 // Reposition clip for printing layout
 flip_clip = 1;
 
 
 // Contact area
 // Critical dimensions to fit the socket are:
 //
 // Edge guides: fit in slot 1mm high, 1.2mm wide
 //
 // Contact area: 3.3mm high, 7.90 wide (not inc edge guides)
 //
 // Total plug width 10.4 (7.9 + 1.2*2)
 //
 // Total plug height max 4.3 (1.0 + 3.3)
 //
 // Total plug contact area depth something appx 5.65..5.90
 //
 // Connector pitch is same as standard SATA cable: 1.27mm i.e 0.05in, or 1/2 the "standard" 2.54 or 0.10 inch pitch. Pin width is half the "standard" 0.635 mm or 0.025in, at 0.3175mm or 0.0125in.
 //
 // Note plug has some alignment features too. Small insets on sides for protrusions in socket to engage with. Small bump on end of contact area to align contacts by engaging with deepest part of socket.

contact_holder_contacts_width = 7.9;
contact_holder_edge_guide_width = 1.2;
// Therefore total width of plug is approx 10.25 or 10.30
contact_holder_total_width = contact_holder_contacts_width + contact_holder_edge_guide_width*2;

// This should add up to the contact holder thickness of 4.0mm.
// Some adjustment will be required.
contact_holder_edge_guide_height = 0.95;
contact_holder_contact_inset_height = 0.30;
contact_holder_base_height = 2.75;

contact_holder_total_height = contact_holder_edge_guide_height + contact_holder_contact_inset_height + contact_holder_base_height;

// Standard pitch, same as SATA. Separation varies with contact width, this is for flat trace style contacts. The contacts should be centered and evenly spaced. Contact height can vary a bit by the looks, the contacts are sprung on the socket end.
contact_count = 6;
contact_pitch = 1.27;
contact_width = 0.3175;
contact_height = 0.2;
contact_inset_width = contact_pitch/2;
// How far the contact grooves should extend into the handle part
contact_inset_extra_length = 2.5;

// notch placement for where contacts should slot into plug - distance from end
contact_termination_hole_length_inset = 0.3;
contact_termination_hole_length = contact_width*3;

contact_holder_length = 5.90;

// Less dimensoinally critical, the handle part
handle_length = 7.8;
handle_width = 13.9;
handle_height = 6.4;

// cable-hole area in handle
handle_cable_hole_width = contact_pitch*6;
handle_cable_hole_height = contact_pitch*2;

// side-grip notches in sides of plug
side_notch_xoff = 3.5;
side_notch_x = 0.8;
side_notch_y = 0.2;

s = 0.001;

// Plug part
module plug() {
difference()
{
    // Form a solid to cut pieces out from
    union() {
        
        // Main contact area chunk
        cube([
            contact_holder_length,
            contact_holder_total_width,
            contact_holder_total_height
            ]);
            
        // The holder part. Dimensions aren't so critical, but might as well
        // match the original.
        translate([
            -handle_length +s,
            -(handle_width - contact_holder_total_width)/2,
            -(handle_height - contact_holder_total_height)/2
        ])
        difference()
        {
            cube([
                handle_length+2*s,
                handle_width,
                handle_height
            ]);
        }
    }

    // Cut the way between the contacts on the contact area, removing the edge-guide part.
    translate([
        -s,
        -s + contact_holder_edge_guide_width,
        -s + contact_holder_base_height + contact_holder_contact_inset_height
    ])
    cube([
        contact_holder_length + 2*s,
        contact_holder_contacts_width + 2*s,
        contact_holder_edge_guide_height + 2*s
        ]);
    
    // In the main contacts area, cut inset grooves for the contacts to ride in. These can be customised. They deliberately extend into the handle-part.
    let(contact_edge_inset = (contact_holder_contacts_width - (6*contact_pitch))/2)
    translate([0, contact_holder_edge_guide_width + contact_edge_inset, 0])
    {
        // Main contacts area
        for (c = [1 : 6]) {
            // Pitch is the critical factor in contact placement.  At a pitch of 1.27mm, the width is 7.62mm. The measured 7.9 is because there are lips on the edges. Place contacts from center out. This is the cutouts.
            // This both makes the wire channels in the front and the holes for the conductors in the back plug cutout.
            translate([0, (contact_pitch - contact_inset_width)/2, 0])
            {
                translate([
                    -s - contact_inset_extra_length,
                    (c-1)*contact_pitch
                    ,contact_holder_base_height
                ])
                cube([
                    contact_holder_length + contact_inset_extra_length+s*2,
                    contact_inset_width,
                    contact_holder_contact_inset_height
                    ]);
                
                // Cut notches for the contacts to slot into to hold
                // them in place. These go near the end of the plug. Back-sloped so they tend to hold position.
                
                translate([
                    contact_holder_length - contact_termination_hole_length_inset - contact_height,
                    (c-1)*contact_pitch,
                    contact_holder_base_height
                ])
                rotate([0,25,0])
                translate([
                    0,
                    (contact_pitch/2 - contact_width)/2,
                    -contact_termination_hole_length*0.95
                ])
                cube([
                    contact_height+s,
                    contact_width+s,
                    contact_termination_hole_length
                ]);
                
                // Cut the holes for the conductors through the plug hole a bit bigger
                // so it's easier to run them.
                translate([
                    -s-contact_inset_extra_length,
                    (c-1)*contact_pitch,
                    contact_holder_base_height - contact_holder_contact_inset_height/2
                ])
                cube([
                    contact_inset_extra_length+4*s,
                    contact_inset_width,
                    contact_holder_contact_inset_height*2
                    ]);
            }
        }
    }
    
    // Cut out the cable space in the plug connector, not including the individual
    // conductor channel holes.
    translate([
        -s - handle_length,
        abs(handle_cable_hole_width-contact_holder_total_width)/2,
        (contact_holder_base_height+contact_holder_contact_inset_height)/2
    ])
    cube([
        handle_length - contact_inset_extra_length + s,
        handle_cable_hole_width,
        handle_cable_hole_height
    ]);
    
    // Cut out the notches for the side grips to engage.
    for (i = [0,1])
    translate([
        side_notch_xoff,
        -s + i*(contact_holder_total_width-side_notch_y),
        -s
    ])
    cube([
        side_notch_x,
        side_notch_y+2*s,
        contact_holder_total_height+2*s
    ]);
        
}
}

// Support cutting out a separate clip in the handle
//
// The clip tolerance should be +ve for the clip and negative when used as a mask. It affects the clip tooth size and clip width and length.
module plug_clamp(clip_tolerance) {
union()
{
    // Clampdown area over contacts
    translate([
        -s - contact_inset_extra_length,
        -s + contact_holder_edge_guide_width - clip_tolerance/2,
        -s + contact_holder_base_height + contact_holder_contact_inset_height
    ])
    cube([
        contact_inset_extra_length + 2*s,
        contact_holder_contacts_width + 2*s + clip_tolerance,
        contact_holder_edge_guide_height + 2*s
        ]);

    // lid
    translate([
        -handle_length -s,
        -s -(handle_width - contact_holder_total_width)/2,
        contact_holder_total_height-s
    ])
    difference()
    {
        cube([
            handle_length+6*s,
            handle_width+2*s,
            (handle_height - contact_holder_total_height)/2 + 2*s
        ]);
    }
    
    // cutouts in sides for clips
    let(
        clip_length = handle_length/2 + clip_tolerance,
        clip_width = (handle_width - contact_holder_total_width)/6 + clip_tolerance,
        clip_height = contact_holder_total_height * 0.75,
        clip_tooth_length = clip_width,
        clip_tooth_width = clip_width
    )
    translate([
        -handle_length * 0.75 - clip_tolerance/2,
        0,
        contact_holder_total_height - clip_height - clip_tolerance/2
    ])
    {
        translate([0, -(handle_width - contact_holder_total_width)/2 - s, 0])
        {
            cube([clip_length, clip_width, clip_height + abs(clip_tolerance)]);
        
            translate([0, clip_width - s, 0])
            cube([clip_length, clip_tooth_width + s, clip_tooth_length + clip_tolerance/2]);
        }
        
        translate([0, handle_width/2 + contact_holder_total_width/2 - clip_width + s, 0])
        {
            cube([clip_length, clip_width, clip_height + abs(clip_tolerance)]);
            
            translate([0, -clip_width - s, 0])
            cube([clip_length, clip_tooth_width + 2* s, clip_tooth_length]);
        }
    }
    
    // Notches to press down on the conductors in their channels
    translate([
        -contact_inset_extra_length,
        contact_holder_total_width/2,
        contact_holder_base_height + contact_holder_contact_inset_height/2
    ])
    for (c = [1:6]) {
    let(coff = (c-3.5)*contact_pitch - contact_width/2)
    translate([0, coff , 0])
    cube([
        contact_inset_extra_length,
        contact_width,
        contact_height
    ]);
}
}
}

module plug_base(clip_tolerance) {
    difference() {
        plug();
        plug_clamp(-clip_tolerance);
    }
}


translate([0,0,contact_holder_base_height/2])
{
    if (render_base) plug_base(0);

    if (render_clip) {
        let (
            clip_rotate = flip_clip ? 180 : 0,
            clip_xoff = flip_clip ? (contact_holder_length + handle_length + 10) : 0,
            clip_yoff = flip_clip ? -contact_holder_total_width : 0,
            clip_zoff = flip_clip ? -contact_holder_total_height : 0
        )
        rotate([clip_rotate,0,0])
        translate([clip_xoff, clip_yoff, clip_zoff])
        color("red") plug_clamp(-0.1);
    }

    // Model the contacts too. Place them from center out.
    if ($preview)
    color("red", 0.5)
    translate([
        -handle_length,
        contact_holder_total_width/2,
        contact_holder_base_height
    ])
    for (c = [1:6]) {
        let(coff = (c-3.5)*contact_pitch - contact_width/2)
        translate([0, coff , 0])
        cube([
            contact_holder_length+handle_length,
            contact_width,
            contact_height
        ]);
    }
}