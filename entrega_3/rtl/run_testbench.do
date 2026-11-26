quit -sim

if {[file exists work]} {
    vdel -lib work -all
}
vlib work
vmap work work

proc sort_vhd_files {files} {
    set provides [dict create]
    set contents [dict create]
    set all_files {}

    foreach f $files {
        if {![file exists $f]} { continue }
        lappend all_files $f
        set fp [open $f r]
        set data [string tolower [read $fp]]
        close $fp
        dict set contents $f $data

        foreach {_, name} [regexp -all -inline {\mpackage\s+(?!body\s)([a-z0-9_]+)} $data] {
            dict set provides $name $f
        }
        foreach {_, name} [regexp -all -inline {\mentity\s+([a-z0-9_]+)} $data] {
            dict set provides $name $f
        }
    }

    set ordered {}
    set visiting [dict create]
    set visited [dict create]

    proc dfs {f provides contents visiting_ref visited_ref ordered_ref} {
        upvar 1 $visiting_ref visiting
        upvar 1 $visited_ref visited
        upvar 1 $ordered_ref ordered

        if {[dict exists $visited $f]} { return }
        if {[dict exists $visiting $f]} { return }
        dict set visiting $f 1

        set data [dict get $contents $f]

        foreach {_, dep_name} [regexp -all -inline {\mwork\.([a-z0-9_]+)} $data] {
            if {[dict exists $provides $dep_name]} {
                set dep_file [dict get $provides $dep_name]
                if {$dep_file ne $f} {
                    dfs $dep_file $provides $contents visiting visited ordered
                }
            }
        }

        foreach {_, dep_name} [regexp -all -inline {\m[a-z0-9_]+\s*:\s*(?:entity\s+(?:work\.)?)?([a-z0-9_]+)} $data] {
            if {[dict exists $provides $dep_name]} {
                set dep_file [dict get $provides $dep_name]
                if {$dep_file ne $f} {
                    dfs $dep_file $provides $contents visiting visited ordered
                }
            }
        }

        dict unset visiting $f
        dict set visited $f 1
        lappend ordered $f
    }

    foreach f $all_files {
        if {[string tolower $f] eq "testbench.vhd"} { continue }
        dfs $f $provides $contents visiting visited ordered
    }
    if {[file exists "testbench.vhd"]} {
        lappend ordered "testbench.vhd"
    }
    return $ordered
}

set vhd_list [glob -nocomplain *.vhd]
set sorted_list [sort_vhd_files $vhd_list]

puts "Ordem detectada: $sorted_list"
foreach f $sorted_list {
    vcom -2008 $f
}

puts "================ paga uma coca se isso funcionar ================"
vsim -voptargs=+acc work.testbench
add wave -r /*
run -all
wave zoom full