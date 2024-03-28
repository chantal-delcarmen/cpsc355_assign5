// File: a5b.asm
// CPSC 355 Assignment 5
// Chantal del Carmen
// Student #: 30129615

            .text
            
define(i_r, w19)
define(argc_r, w20)
define(argv_r, x21)
define(month_r, w22)
define(day_r, w23)
define(season_r, w24)
define(base_r, w25)
define(suffix_r, w26)

fmt:        .string "%s\n"
fmt_error:  .string "usage: a5b mm dd"
fmt_r_error:.string "Day or month is out of range"

// Months
jan_m:      .string "January"
feb_m:      .string "February"
mar_m:      .string "March"
apr_m:      .string "April"
may_m:      .string "May"
jun_m:      .string "June"
jul_m:      .string "July"
aug_m:      .string "August"
sep_m:      .string "September"
oct_m:      .string "October"
nov_m:      .string "November"
dec_m:      .string "December"

// Seasons
spring_m:   .string "Spring"
summer_m:   .string "Summer"
fall_m:     .string "Fall"
winter_m:   .string "Winter"

// Suffixes
st_m:       .string "st"
nd_m:       .string "nd"
rd_m:       .string "rd"
th_m:       .string "th"

            .data                                               // Creating array of pointers
            .balign 8                                           // Double-word aligned
season_m:   .dword  spring_m, summer_m, fall_m, winter_m
month_m:    .dword  jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m
suffix_m:   .dword  st_m, nd_m, rd_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, st_m, nd_m, rd_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, st_m

            .text
            .balign 4
            .global main
main:       stp     x29, x30, [sp, -16]!
            mov     x29, sp

            mov     argc_r, w0                                  // Copy argc into register
            mov     argv_r, x1                                  // Copy argv into register
            
            cmp     argc_r, 2                                   // Compare if argc_r to 2
            b.ne    error                                       // If num of args != 2, jump to error 
                                                                // Else, fall through

load_input: mov     i_r, 0                                      // i = 0
            ldr     x0, [argv_r, i_r, SXTW 3]                   // x0 = loaded 1st argument
            bl      atoi                                        // Convert string to int and return in w0
            mov     month_r, w0                                 // Move value to month reg

            cmp     month_r, 1                                  // Check that month input is between 1 and 12
            b.lt    range_err                                   // Otherwise, jump to range_err

            cmp     month_r, 12
            b.gt    range_err

            mov     i_r, 1                                      // i = 0
            ldr     x0, [argv_r, i_r, SXTW 3]                   // x0 = loaded 1st argument
            bl      atoi                                        // Convert string to int and return in w0
            mov     day_r, w0                                   // Move value to day reg

            cmp     day_r, 1                                    // Check that day input is between 1 and 31
            b.lt    range_err                                   // Otherwise, jump to range_err

            cmp     day_r, 31
            b.gt    range_err

season:     adrp    base_r, season_m                            // Calculate base array address
            add     base_r, base_r, :lo12:season_m                     

range_err:  ldr     x0, =fmt_r_error                            // Jump here if month or day input is out of range
            bl      printf                                      // Print error message
            b       done

error:      ldr     x0, =fmt_error                              // Jump here if arguments is != 2
            bl      printf                                      // Print error message

done:       ldp     x29, x30, [sp], 16                          // Exit program
            ret
