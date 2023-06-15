include <lib.scad>

function in2mm(inch)=inch*25.4;
function mult_v3(a,v3)=[a*v3[0], a*v3[1], a*v3[2]];

module place( thing, align=[0,0,-1]) {
  translate([
    -align.x*0.5*thing.x, 
    -align.y*0.5*thing.y, 
    -align.z*0.5*thing.z])
    children();
}
module place_cube( thing, align=[0,0,-1]) {
  translate([
    -align.x*0.5*thing.x, 
    -align.y*0.5*thing.y, 
    -align.z*0.5*thing.z])
    cube(thing, center=true);
}


// DIN rail clamp
clamp_width = 10;
clamp_color = "darkolivegreen";
module make_clamp_base() {
  color(clamp_color)
  translate([0,0.5*clamp_width,0])
  difference() {
    rotate(90,[1,0,0])
      linear_extrude(height=clamp_width, convexity=10)
        import("din-rail-clamp.dxf");
    // screwdriver release slot/pocket
    box = [1.25, clamp_width-3, 5 ];
    translate([-18.6,-1,-13.8])
      place(box, [1,1,-1])
        cube(box, center=true);
  }
}

din_length = 43;
din_width = 10;
din_base_thick = 8;
din_size = [ din_width, din_length, din_base_thick ];
din_clip_thick = 8;
din_clip_size = [ din_width, din_length, din_clip_thick ];
din_hole_dia = 3;
din_hole_free_dia = 3.2;
din_hole_depth = 5;
// din_hole_posns = [-12.5, 0, 12.5];
din_hole_posns = [-12.5, 12.5];
din_fudge = 0.05;
module place_din_mount(off=[0,0,0]) {
  color("darkgreen")
  translate(off) {
    difference() {
      translate([0,0,-0.5*din_size.z] )
        cube(  din_size, center=true );
      for( y = din_hole_posns ) {
        translate([0,y, -din_hole_depth+din_fudge])
        cylinder(d=din_hole_dia, h=din_hole_depth);
      }
    }
    translate([0,0,-din_size.z] )
      rotate(90,[0,0,1])
      make_clamp_base();
  }
}

// screws
m3_close = 3.2;
m3_medium = 3.4;
m3_free = 3.6;
m3_head_dia = 6;
m3_head_thk = 0.8;



// PCB size: 0.400 x 2.000 inches 
pcb = [ in2mm(.400), in2mm(2.0), in2mm(0.063) ];

module make_pcb_assy(off=[0,0,0]) {
  color("silver") {
    translate(off)
    translate([-0.5*pcb.x, 0.5*pcb.y, 0.0*pcb.z])
      import("din-io-simulator.stl");
  }
  // #translate([0,0,0.5*pcb.z]) cube(pcb, center=true);
}

wall = 2.0;
high = 10;
base_floor_thick = 7;

pcb_lip = [pcb.x+0.2, pcb.y+0.2, 1.6];
pcb_free = [pcb.x-2, pcb.y-2, 3.2];
base = [pcb_lip.x+2*wall, pcb_lip.y+2*wall, pcb_lip.z + pcb_free.z + base_floor_thick];
wall_overlap = base.z-1;
// base_color = "midnightblue";
base_color = "darkslategray";
echo(base);


pcb_trimmer_posn = [ -3.495, -4.564, high ];
pcb_trimmer_dia = 3.0;
pcb_switch_posn = [ 0, 4.19, high  ];
pcb_switch_dia = in2mm(0.266);
pcb_led_posn = [ 0, 14.605, high ];
pcb_led_dia = 5.4;
pcb_shunt_posn = [ -1.778, -15.240, high ];
pcb_shunt_size = [ 6.15, 3.60, 4*wall ];


engraving_color = "white";
cover_color = "slategray";
plate = [base.x, 37.2, wall];
plate_posn = [0,0.3,high];

vside  = [base.x, wall, high];
vside_posns = [
    [0,  0.5*37.2-0.5*wall+0.3, 0],
    [0, -0.5*37.2+0.5*wall+0.3, 0]
];

pcb_access_hole = 8.5;
hside = [wall, 37.2-pcb_access_hole-wall, high+wall_overlap];
hside_posns = [
    [0.5*base.x-0.5*wall, 0.5*plate.y+0.3, -wall_overlap],
    [-0.5*base.x+0.5*wall,, 0.5*plate.y+0.3, -wall_overlap]
];
hside2 = [wall, 37.2, 2];
hside2_posns = [
    [0.5*base.x-0.5*wall, 0.5*plate.y+0.3, high],
    [-0.5*base.x+0.5*wall, 0.5*plate.y+0.3, high]
];

// M3 threaded insert
m3_insert_dia = 5;
m3_insert_deep = 3.0;
insert_posns = [
  [ 0.5*base.x-wall-0.5*m3_insert_deep, 0, -base.z+0.5*m3_insert_dia+1 ],
  [ -0.5*base.x+wall+0.5*m3_insert_deep, 0, -base.z+0.5*m3_insert_dia+1 ]
];

// M3 connecting screw holes
m3_screw_posns = [
  [  0.5*base.x-0.5*m3_head_thk+0.01, 0, -base.z+0.5*m3_insert_dia+1 ],
  [ -0.5*base.x+0.5*m3_head_thk-0.01, 0, -base.z+0.5*m3_insert_dia+1 ]
];
// font = "Liberation Sans";
// font = "Courier New:style=Bold";
font = "D2Coding:style=Bold";
module mytext( position, angle, string, height, alignh, alignv, kind="red", txt_height=0.05) {
  color(kind)
    translate( position )
      rotate(angle,[0,0,1])
        linear_extrude(height = txt_height)
          text(text = string, font = font, size = height, halign = alignh, valign = alignv);
}

label_wid = 12;
label_color = "white";
label = [ 0.02+base.x, label_wid, 0.1 ];
label_posn = [0, -12.25, high+wall];
module make_label() {
  color(label_color)
    translate(label_posn)
      cube( label, center=true );
  color("black")
    translate(label_posn+[0,0,+0.01]) {
      mytext( [0,2,0], 0, "SIGNAL", 3, "center", "center");
      mytext( [0,-2,0], 0, "LABEL", 3, "center", "center");
    }
}

module place_pcb_assy() {
  translate([0,0,-pcb.z])
    make_pcb_assy();
}

module make_base(infill=false) {
  color(base_color)
  difference() {
    // main base
    place_cube(base,[0,0,1]);
    // recess for pcb lip
    translate([0,0,0.1])
      place_cube(pcb_lip+[0,0,0.1], [0,0,1]);
    // recess for pins on bottom of pcb
    translate([0,0,-pcb_lip.z+0.01])
      place_cube(pcb_free, [0,0,1]);
    // cutout for sides
    for(posn=hside_posns) {
      translate(posn + [0,0.1,-0.1])
        place_cube(hside+[0.2,0.2,0.2],[0,1,-1]);
    }
    // holes for M3 nut inserts
    for(posn=insert_posns) {
      translate(posn)
        rotate(90,[0,1,0])
        cylinder(d=m3_insert_dia, h=m3_insert_deep, center=true);
    }
    // clearance for m3 retaining screw
    translate([0,0,insert_posns[0].z])
    rotate(90,[0,1,0])
      cylinder(d=m3_medium, h=2*base.x, center=true);

    // DIN clamp screw holes
    for( y = din_hole_posns ) {
      translate([0,y,0]) {
        translate([0,0,-base.z])
          cylinder(d=m3_free, h=2*base_floor_thick, center=true);
        translate([0,0,-base.z+base_floor_thick-m3_head_thk+din_fudge])
          cylinder(d=m3_head_dia, h=2*m3_head_thk, center=true);
      }
    }
    // I/O Connector Labels
    translate([ 0, -0.5*base.y+txt_engraving_depth, 0 ]) {
      rotate(90,[1,0,0]) {
        translate([4,-1.5,0]) cylinder(d=1.25, h=txt_engraving_depth+0.1); // pin-1 dot
        mytext( [+4,-3,0], 90,  "+V", 2.5, "right", "center",txt_height=txt_engraving_depth+0.1);
        mytext( [ 0,-3,0], 90, "GND", 2.5, "right", "center",txt_height=txt_engraving_depth+0.1);
        mytext( [-4,-3,0], 90, "SIG", 2.5, "right", "center",txt_height=txt_engraving_depth+0.1);
      }
    }
    translate([ 0, +0.5*base.y-txt_engraving_depth, 0 ]) {
      rotate(-90,[1,0,0]) {
        translate([-4,1.5,0]) cylinder(d=1.25, h=txt_engraving_depth+0.1); // pin-1 dot
        mytext( [-4,3,0], 90,  "+V", 2.5, "left", "center",txt_height=txt_engraving_depth+0.1);
        mytext( [ 0,3,0], 90, "GND", 2.5, "left", "center",txt_height=txt_engraving_depth+0.1);
        mytext( [+4,3,0], 90, "SIG", 2.5, "left", "center",txt_height=txt_engraving_depth+0.1);
      }
    }
  }
  if(infill) { 
    color(engraving_color) {
      // I/O Connector Labels
      translate([ 0, -0.5*base.y+txt_engraving_depth, 0 ]) {
        rotate(90,[1,0,0]) {
          translate([4,-1.5,0]) cylinder(d=1.25, h=txt_engraving_depth+0.1); // pin-1 dot
          mytext( [+4,-3,0], 90,  "+V", 2.5, "right", "center",txt_height=txt_engraving_depth+0.1);
          mytext( [ 0,-3,0], 90, "GND", 2.5, "right", "center",txt_height=txt_engraving_depth+0.1);
          mytext( [-4,-3,0], 90, "SIG", 2.5, "right", "center",txt_height=txt_engraving_depth+0.1);
        }
      }
      translate([ 0, +0.5*base.y-txt_engraving_depth, 0 ]) {
        rotate(-90,[1,0,0]) {
          translate([-4,1.5,0]) cylinder(d=1.25, h=txt_engraving_depth+0.1); // pin-1 dot
          mytext( [-4,3,0], 90,  "+V", 2.5, "left", "center",txt_height=txt_engraving_depth+0.1);
          mytext( [ 0,3,0], 90, "GND", 2.5, "left", "center",txt_height=txt_engraving_depth+0.1);
          mytext( [+4,3,0], 90, "SIG", 2.5, "left", "center",txt_height=txt_engraving_depth+0.1);
        }
      }
    }
  }
}
module place_base(infill=true) {
  make_base(infill);
}
module print_base() {
  translate([0,0,base.z])
    make_base();
}

txt_engraving_depth = 0.3;
module make_cover(infill=false) {
  color(cover_color) 
  difference(){
    union() {
      // top plate/panel of switch
      translate(plate_posn)
        place_cube(plate,[0,0,-1]);

      // horizontal sides, main ones
      for(posn=hside_posns) {
        translate(posn)
          place_cube(hside,[0,1,-1]);
      }
      // horizontal sides, short sides
      for(posn=hside2_posns) {
        translate(posn)
          place_cube(hside2,[0,1,1]);
      }
      // vertical sides
      for(posn=vside_posns) {
        translate(posn)
          place_cube(vside,[0,0,-1]);
      }
    }
    // holes
    translate( pcb_switch_posn+[0,0,-0.5*wall] ) 
      cylinder(h=2*wall, d=pcb_switch_dia);
    translate( pcb_led_posn+[0,0,-0.5*wall] ) 
      cylinder(h=2*wall, d=pcb_led_dia);
    translate( pcb_trimmer_posn+[0,0,-0.5*wall] ) 
      cylinder(h=2*wall, d=pcb_trimmer_dia);

    // holes for M3 connecting screws
    for(posn=m3_screw_posns) {
      hull() {
        translate(posn)
          rotate(90,[0,1,0])
          cylinder(d=m3_head_dia, h=m3_head_thk, center=true);
        translate(posn+[0,0,-10])
          rotate(90,[0,1,0])
          cylinder(d=m3_head_dia, h=m3_head_thk, center=true);
      }
    }
    // clearance for m3 retaining screw
    hull() {
      translate([0,0,m3_screw_posns[0].z])
        rotate(90,[0,1,0])
          cylinder(d=m3_medium, h=2*base.x, center=true);
      translate([0,0,m3_screw_posns[0].z-10])
        rotate(90,[0,1,0])
          cylinder(d=m3_medium, h=2*base.x, center=true);
    }

    // switch labels
    translate( pcb_switch_posn ) {
      translate([ 0.5*base.x-txt_engraving_depth, 0, -3 ])
        rotate(90,[0,0,1])
        rotate(90,[1,0,0]) {
          mytext( [4,0,0],  -90, "ON",   2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
          mytext( [-4,0,0], -90, "(ON)", 2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
          mytext( [0,0,0],  -90, "OFF",  2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
        }
      translate([ -0.5*base.x+txt_engraving_depth, 0, -3 ])
        rotate(90,[0,0,1])
        rotate(-90,[1,0,0]) {
          mytext( [4,0,0],  -90, "ON",   2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
          mytext( [-4,0,0], -90, "(ON)", 2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
          mytext( [0,0,0],  -90, "OFF",  2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
        }
    }

  }
  if(infill) {
    color(engraving_color) {
    // switch labels
      translate( pcb_switch_posn ) {
        translate([ 0.5*base.x-txt_engraving_depth, 0, -3 ])
          rotate(90,[0,0,1])
          rotate(90,[1,0,0]) {
            mytext( [4,0,0],  -90, "ON",   2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
            mytext( [-4,0,0], -90, "(ON)", 2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
            mytext( [0,0,0],  -90, "OFF",  2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
          }
        translate([ -0.5*base.x+txt_engraving_depth, 0, -3 ])
          rotate(90,[0,0,1])
          rotate(-90,[1,0,0]) {
            mytext( [4,0,0],  -90, "ON",   2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
            mytext( [-4,0,0], -90, "(ON)", 2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
            mytext( [0,0,0],  -90, "OFF",  2.5, "center", "center",txt_height=txt_engraving_depth+0.1);
          }
      }
    }
  }


}
module place_cover(infill=true) {
    make_cover(infill);
}
module print_cover() {
  translate([0,0,high+wall])
  rotate(180,[0,1,0])
      make_cover();
}

// view = "assy";
view = "print";
// which = "cover";
// which = "base";
which = "both";
cover_open = 0.0;
// cover_open = 12.0;


if(view == "print") {
  if(which == "both" || which == "base")
    translate([+0.6*base.x,0,0])
      print_base();
  if(which == "both" || which == "cover")
    translate([-0.6*base.x,0,0])
      print_cover();
} else if(view == "assy") {
  // place_pcb_assy();
  // make_label();
  if(which == "both" || which == "base")
    place_base();
  if(which == "both" || which == "cover")
    translate([0,0,cover_open])
      place_cover();
}


// nut(M3_nut);
// insert(F1BM3);
