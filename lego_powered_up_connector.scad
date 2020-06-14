/*
 * Attempt to design Powered Up-compatible power/data connector.
 */
 
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

contact_holder_length = 5.90;

// Less dimensoinally critical, the handle part
handle_width = 13.9;
handle_length = 7.8;
handle_height = 7.4;

s = 0.001;

// Plug part
difference()
{
    // Main contact area chunk
    cube([
        contact_holder_length,
        contact_holder_total_width,
        contact_holder_total_height
        ]);

    // Cut the way between the contacts
    for (i = [0,1])
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
    
    let(contact_edge_inset = (contact_holder_contacts_width - (6*contact_pitch))/2)
    translate([0, contact_holder_edge_guide_width + contact_edge_inset, 0])
    {
        // Main contacts area
        for (c = [1 : 6]) {
            // Pitch is the critical factor in contact placement.  At a pitch of 1.27mm, the width is 7.62mm. The measured 7.9 is because there are lips on the edges. Place contacts from center out. This is the cutouts.
            translate([0, (contact_pitch - contact_inset_width)/2, 0])
            translate([-s, (c-1)*contact_pitch ,contact_holder_base_height])
            cube([
                contact_holder_length+s*2,
                contact_inset_width,
                contact_holder_contact_inset_height
                ]);
        }
    }
};

// The holder part. Dimensions aren't so critical, but might as well
// match the original.
translate([
    -handle_length +s,
    -(handle_width - contact_holder_total_width)/2,
    -(handle_height - contact_holder_total_height)/2
])
cube([
    handle_length,
    handle_width,
    handle_height
]);

// Model the contacts too. Place them from center out.
color("red")
translate([
    0,
    contact_holder_total_width/2,
    contact_holder_base_height
])
for (c = [1:6]) {
    let(coff = (c-3.5)*contact_pitch - contact_width/2)
    translate([0, coff , 0])
    cube([
        contact_holder_length,
        contact_width,
        contact_height
    ]);
}