/* ============================================================================
   Project      : Parametric U-Joint Generator
   File         : u_joint_v2.scad
   Author       : Samet Ozer
   Role         : Mechanical Design / Parametric CAD Modeling
   Description  : Parametric OpenSCAD model of a 3D-printable universal joint
                  (U-joint) consisting of two fork mounts, orthogonal cross
                  pins, and a central spherical hub.

   Parameters   : R           -> Main size parameter controlling joint scale
                  clearance   -> Radial gap between pin and hole (print tolerance)

   Units        : mm

   Notes        : Geometry and algorithm are preserved from original design.
                  Clearance is defined as a fixed value for consistent printability.
                  Surface resolution is controlled via fn_detail.

   Version      : 2.0
   ============================================================================ */


// ============================================================================
// Global Rendering Settings
// ============================================================================

// Increased surface resolution for smoother cylinders and spheres

fn_detail = 48;
R = 10;

// ============================================================================
// Single Fork / Mount Module
// ============================================================================

module mount(
    R = 10,
    clearance = 0.25
) {
    // ------------------------------------------------------------------------
    // Derived dimensions
    // ------------------------------------------------------------------------
    mount_outer_r = R / 2;
    mount_disk_h  = R * 0.20;
    mount_body_h  = R * 1.90;
    inner_cut_h   = R * 0.90;

    pin_r         = R * 0.09;
    hole_r        = pin_r + clearance;

    fork_width    = R * 0.46;
    fork_height   = R * 0.60;
    fork_center_z = R * 0.30;
    pin_center_z  = R * 0.60;

    difference() {
        union() {

            // Base connection disk
            cylinder(
                r      = mount_outer_r,
                h      = mount_disk_h,
                center = true,
                $fn    = fn_detail
            );

            // Main fork body
            // A hollowed cylindrical body is intersected with a block-plus-cylinder
            // envelope to retain only the desired mount geometry.
            intersection() {
                difference() {
                    cylinder(
                        r   = mount_outer_r,
                        h   = mount_body_h,
                        $fn = fn_detail
                    );

                    cylinder(
                        r   = mount_outer_r * 0.70,
                        h   = inner_cut_h,
                        $fn = fn_detail
                    );
                }

                union() {
                    // Main fork block region
                    translate([0, 0, fork_center_z])
                        cube(
                            [R, fork_width, fork_height],
                            center = true
                        );

                    // Cylindrical region defining the pin support area
                    translate([0, 0, pin_center_z])
                        rotate([0, 90, 0])
                            cylinder(
                                r      = R * 0.23,
                                h      = R,
                                center = true,
                                $fn    = fn_detail
                            );
                }
            }
        }

        // Cross-pin hole with fixed radial clearance
        translate([0, 0, pin_center_z])
            rotate([0, 90, 0])
                cylinder(
                    r      = hole_r,
                    h      = R * 1.10,
                    center = true,
                    $fn    = fn_detail
                );
    }
}


// ============================================================================
// Full U-Joint Assembly
// ============================================================================

module ujoint(
    R = 10,
    clearance = 0.25
) {
    // ------------------------------------------------------------------------
    // Derived dimensions
    // ------------------------------------------------------------------------
    pin_r        = R * 0.09;
    hub_r        = (R / 2) * 0.65;
    center_z     = R * 0.60;
    spacing_z    = R * 1.20;
    global_shift = -R * 0.60;

    translate([0, 0, global_shift]) {

        // First cross pin (X-axis direction)
        translate([0, 0, center_z])
            rotate([0, 90, 0])
                cylinder(
                    r      = pin_r,
                    h      = R,
                    center = true,
                    $fn    = fn_detail
                );

        // Second cross pin (Y-axis direction)
        translate([0, 0, center_z])
            rotate([90, 0, 0])
                cylinder(
                    r      = pin_r,
                    h      = R,
                    center = true,
                    $fn    = fn_detail
                );

        // Central spherical hub
        translate([0, 0, center_z])
            sphere(
                r   = hub_r,
                $fn = fn_detail
            );

        // Lower mount
        mount(
            R         = R,
            clearance = clearance
        );

        // Upper mount
        translate([0, 0, spacing_z])
            rotate([180, 0, 90])
                mount(
                    R         = R,
                    clearance = clearance
                );
    }
}


// ============================================================================
// Example Usage
// ============================================================================

ujoint(R, clearance = 0.25);