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
    raw == "1_0" ? "q" :
    raw == "1_1" ? "w" :
    raw == "1_2" ? "e" :
    raw == "1_3" ? "r" :
    raw == "1_4" ? "t" :
    raw == "1_5" ? "y" :
    raw == "1_6" ? "u" :
    raw == "1_7" ? "i" :
    raw == "1_8" ? "o" :
    raw == "1_9" ? "p" :
    raw == "1_10" ? "è[é{" :
    raw == "1_11" ? "+]*}" :
    raw == "2_0" ? "a" :
    raw == "2_1" ? "s" :
    raw == "2_2" ? "d" :
    raw == "2_3" ? "f" :
    raw == "2_4" ? "g" :
    raw == "2_5" ? "h" :
    raw == "2_6" ? "j" :
    raw == "2_7" ? "k" :
    raw == "2_8" ? "l" :
    raw == "2_9" ? "ò@ç" :
    raw == "2_10" ? "à#°" :
    raw == "2_11" ? "ù§" :
    raw == "3_0" ? "<>" :
    raw == "3_1" ? "z" :
    raw == "3_2" ? "x" :
    raw == "3_3" ? "c" :
    raw == "3_4" ? "v" :
    raw == "3_5" ? "b" :
    raw == "3_6" ? "n" :
    raw == "3_7" ? "m" :
    raw == "3_8" ? "n" :
    raw == "3_9" ? "m" :
    raw == "3_10" ? ",;" :
    raw == "3_11" ? ".:" :
    raw == "3_12" ? "-_" :
    raw == "a_l" ? "←" :
    raw == "a_r" ? "→" :
    raw == "a_u" ? "↑" :
    raw == "a_d" ? "↓" :
    raw == "win" ? "■■■■" :
    raw; // fallback: use raw input

raw_letter = "text_Enter";
letter = italian_map(raw_letter);


part = "base";
fmt = "enter";

len_str = len(letter);
$fn = 100;

base_side = 18;
enter_h1 = 37;
enter_w1 = 22;
enter_w2 = 26;
enter_h2 = 18.5;
base_height = 2;
fillet_radius = 2.5;
eps = 0.01;
space_stab_d = 50;
enter_stab_d = 12;

cyl_diameter = 5.75;
cyl_height = 4;

cross_width = 1.3;
cross_length = 4.5;
cross_depth = cyl_height;

emboss_height = 0.5;

text_divisor = (len_str == 1) ? 2.5 : ((len_str == 2) ? 4 : (len_str > 4) ? 5 : 4);

module roundedBase() {
    offset(r = fillet_radius)
        offset(delta = -fillet_radius)
            if (fmt == "lshift") square([base_side + 5, base_side], center = true);
            else if (fmt == "rshift" || fmt == "capslock") square([base_side + 14, base_side], center = true);
            else if (fmt == "tab") square([base_side + 10, base_side], center = true);
            else if (fmt == "backspace") square([base_side + 19, base_side], center = true);
            else if (fmt == "enter") {
                
                    union() {
                        square([enter_w1, enter_h1], center = true);
                        translate([((enter_w2)-(enter_w1))/2, (enter_h2)/2])
                            square([enter_w2, enter_h2], center = true);
                    }
          
            }
            else if (fmt == "space") square([base_side +95, base_side], center = true);
            else square([base_side, base_side], center = true);
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

module engravedCylinder() {
    difference() {
        cylinder(d = cyl_diameter, h = cyl_height);
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    if (fmt == "space"){
    translate([space_stab_d, 0, 0])
    difference() {

        cylinder(d = cyl_diameter, h = cyl_height);
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    translate([-space_stab_d, 0, 0])
    difference() {

        cylinder(d = cyl_diameter, h = cyl_height);
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    }
    if (fmt == "enter"){
    translate([0, enter_stab_d, 0])
    difference() {

        cylinder(d = cyl_diameter, h = cyl_height);
        translate([0, 0, cyl_height - cross_depth / 2 + eps])
            crossCutout();
    }
    translate([0, -enter_stab_d, 0])
    difference() {

        cylinder(d = cyl_diameter, h = cyl_height);
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
    engravedSymbol(substr(letter, 0, 1), 0, -base_side * 0.18);
    engravedSymbol(substr(letter, 1), 0, base_side * 0.18);
}

module engraved3Layout() {
    engravedSymbol(substr(letter, 0, 1), base_side * 0.18, -base_side * 0.18);
    engravedSymbol(substr(letter, 1, 1), -base_side * 0.18, -base_side * 0.18);
    engravedSymbol(substr(letter, 2), base_side * 0.18, base_side * 0.18);
}

module engraved4Layout() {
    engravedSymbol(substr(letter, 0, 1), base_side * 0.18, -base_side * 0.18);
    engravedSymbol(substr(letter, 1, 1), -base_side * 0.18, -base_side * 0.18);
    engravedSymbol(substr(letter, 2, 1), base_side * 0.18, base_side * 0.18);
    engravedSymbol(substr(letter, 3), -base_side * 0.18, base_side * 0.18);
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

    translate([0, 0, base_height])
        engravedCylinder();
}

if (part == "text") {
    render_text();
}
