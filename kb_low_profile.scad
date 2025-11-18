include <BOSL2/strings.scad>

function italian_map(raw) =
    raw == "0_0" ? "\\|" :
    raw == "0_1" ? "1!" :
    raw == "0_2" ? "2\"" :
    raw == "0_3" ? "3£" :
    raw == "0_4" ? "4$" :
    raw == "0_5" ? "5%" :
    raw == "0_6" ? "6&" :
    raw == "0_7" ? "7/" :
    raw == "0_8" ? "8(" :
    raw == "0_9" ? "9)" :
    raw == "0_10" ? "0=" :
    raw == "0_11" ? "'?" :
    raw == "0_12" ? "ì^" :
    raw == "1_0" ? "Q" :
    raw == "1_1" ? "W" :
    raw == "1_2" ? "E" :
    raw == "1_3" ? "R" :
    raw == "1_4" ? "T" :
    raw == "1_5" ? "Y" :
    raw == "1_6" ? "U" :
    raw == "1_7" ? "I" :
    raw == "1_8" ? "O" :
    raw == "1_9" ? "P" :
    raw == "1_10" ? "è[é{" :
    raw == "1_11" ? "+]*}" :
    raw == "2_0" ? "A" :
    raw == "2_1" ? "S" :
    raw == "2_2" ? "D" :
    raw == "2_3" ? "F" :
    raw == "2_4" ? "G" :
    raw == "2_5" ? "H" :
    raw == "2_6" ? "J" :
    raw == "2_7" ? "K" :
    raw == "2_8" ? "L" :
    raw == "2_9" ? "ò@ç" :
    raw == "2_10" ? "à#°" :
    raw == "2_11" ? "ù§" :
    raw == "3_0" ? "<>" :
    raw == "3_1" ? "Z" :
    raw == "3_2" ? "X" :
    raw == "3_3" ? "C" :
    raw == "3_4" ? "V" :
    raw == "3_5" ? "B" :
    raw == "3_6" ? "N" :
    raw == "3_7" ? "M" :
    raw == "3_8" ? ",;" :
    raw == "3_9" ? ".:" :
    raw == "3_10" ? "-_" :
    raw == "a_l" ? "◀" :
    raw == "a_r" ? "▶" :
    raw == "a_u" ? "▲" :
    raw == "a_d" ? "▼" :
    raw == "win" ? "■■■■" :
    raw; // fallback: use raw input

raw_letter = "text_PrtSc";
letter = italian_map(raw_letter);

support = true;
part = "base";
fmt = "std";

len_str = len(letter);
$fn = 100;

base_side = 16;

base_side_w = (fmt == "lshift") ? base_side+5 :
(fmt == "rshift") ? base_side+14 :
(fmt == "capslock") ? base_side+14 :
(fmt == "tab") ? base_side+10 :
(fmt == "backspace") ? base_side+19 :
(fmt == "space") ? base_side+95 :
(fmt == "enter") ? base_side+4 :
base_side;


base_height = 2;
fillet_radius = 2.5;
eps = 0.01;
space_stab_d = 50;
enter_stab_d = 12;

cyl_diameter = 5.75;
cyl_height = 4;

cross_width = 1.2;
cross_length = 4.3;
cross_depth = cyl_height;

emboss_height = 0.1;

distance_factor = (letter == "■■■■") ? 0.1 : 0.18;
pos = base_side * distance_factor;
text_divisor = (len_str == 1) ? 2.5 : ((len_str == 2) ? 4 : (len_str > 4) ? 5 : 4);

module roundedBase() {
    offset(r = fillet_radius)
        offset(delta = -fillet_radius)
            if (fmt == "enter") {
                
                    union() {
                        square([base_side_w, base_side+19], center = true);
                        translate([(base_side_w)/2, (base_side+19)/4])
                            square([base_side*0.45, (base_side+19)/2], center = true);
                    }
          
            }
            
            else square([base_side_w, base_side], center = true);
}

module baseBlock() {
    linear_extrude(height = base_height)
        roundedBase();
}

module crossCutout() {
    union() {
        cube([cross_length, cross_width, cross_depth + eps], center = true);
        cube([cross_width, cross_length, cross_depth + eps], center = true);
    }
}

module crossSupport() {
    translate([0,0,cyl_height-0.2]) {
    union() {
        //cube([base_side_w, 0.5, 0.4], center=true);
        cube([0.5,base_side, 0.4], center=true); 
    }
    }
}

module supportedCylinder() {
    cylinder(d = cyl_diameter, h = cyl_height);
    crossSupport();

}

module engravedCylinder() {
    difference() {
        supportedCylinder();
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    if (fmt == "space"){
    translate([space_stab_d, 0, 0])
    difference() {

        supportedCylinder();
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    translate([-space_stab_d, 0, 0])
    difference() {

        supportedCylinder();
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    }
    if (fmt == "enter"){
    translate([0, enter_stab_d, 0])
    difference() {

        supportedCylinder();
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    translate([0, -enter_stab_d, 0])
    difference() {

        supportedCylinder();
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    }
}

module engravedSymbol(textChar, x, y, e = 0.01) {
    translate([x, y, 0])
        mirror([1, 0, 0])
            linear_extrude(height = emboss_height + e)
                text(textChar,
                     font = "Liberation Sans:style=Bold",
                     size = base_side / text_divisor,
                     halign = "center",
                     valign = "center");
}

module engraved1Layout() {
    engravedSymbol(letter, 0, 0);
}

module engraved2Layout() {
    engravedSymbol(substr(letter, 0, 1), 0, -pos);
    engravedSymbol(substr(letter, 1), 0, pos);
}

module engraved3Layout() {
    engravedSymbol(substr(letter, 0, 1), pos, -pos);
    engravedSymbol(substr(letter, 1, 1), -pos, -pos);
    engravedSymbol(substr(letter, 2), pos, pos);
}

module engraved4Layout() {
    engravedSymbol(substr(letter, 0, 1), pos, -pos);
    engravedSymbol(substr(letter, 1, 1), -pos, -pos);
    engravedSymbol(substr(letter, 2, 1), pos, pos);
    engravedSymbol(substr(letter, 3), -pos, pos);
}

module engravedTextLayout() {
    engravedSymbol(substr(letter, 5), 0, 0);
}

module render_text() {
    if (len_str == 1) engraved1Layout();
    else if (len_str == 2) engraved2Layout();
    else if (len_str == 3) engraved3Layout();
    else if (len_str == 4) engraved4Layout();
    else engravedTextLayout();
}

if (part == "base") {
    difference() {
        baseBlock();
        render_text();  // subtract engraved letters
    }
    
    
    
if (support) {
    // border for support
    difference(){
    {translate([0, 0, base_height])
    linear_extrude(height = cyl_height)
    
    roundedBase();
    }
    
    {translate([0, 0, base_height-eps])
    linear_extrude(height = cyl_height+2*eps)
    offset(r = -0.6)
    
    roundedBase();
    }
    }
}

    translate([0, 0, base_height])
    engravedCylinder();

}

if (part == "text") {
    render_text();
}
