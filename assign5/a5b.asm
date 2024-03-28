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
define(base_r, x25)
define(suffix_r, w26)

fmt:        .string "%s %d%s is %s\n"
fmt_error:  .string "usage: a5b mm dd\n"
fmt_r_error:.string "Day or month given is out of range\n"

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
winter_m:   .string "Winter"
spring_m:   .string "Spring"
summer_m:   .string "Summer"
fall_m:     .string "Fall"

// Suffixes
st_m:       .string "st"
nd_m:       .string "nd"
rd_m:       .string "rd"
th_m:       .string "th"

// Creating arrays of pointers for seasons, months and suffixes
            .data                                               
            .balign 8                                           // Double-word aligned
season_m:   .dword  winter_m, spring_m, summer_m, fall_m
month_m:    .dword  jan_m, feb_m, mar_m, apr_m, may_m, jun_m, jul_m, aug_m, sep_m, oct_m, nov_m, dec_m
suffix_m:   .dword  st_m, nd_m, rd_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, st_m, nd_m, rd_m, th_m, th_m, th_m, th_m, th_m, th_m, th_m, st_m

            .text
            .balign 4
            .global main
main:       stp     x29, x30, [sp, -16]!                        // Allocate memory
            mov     x29, sp                                     // Move stack pointer into x29

            mov     argc_r, w0                                  // Copy argc into register
            mov     argv_r, x1                                  // Copy argv into register

            cmp     argc_r, 3                                   // Compare if correct number of arguments given
            b.ne    error                                       // If num of args is incorrect, jump to error 
                                                                // Else, fall through

load_input: mov     i_r, 1                                      // i = 1
            ldr     x0, [argv_r, i_r, SXTW 3]                   // x0 = loaded 1st argument
            bl      atoi                                        // Convert string to int and return in w0
            mov     month_r, w0                                 // Move value to month reg

            mov     i_r, 2                                      // i = 1
            ldr     x0, [argv_r, i_r, SXTW 3]                   // x0 = loaded 1st argument
            bl      atoi                                        // Convert string to int and return in w0
            mov     day_r, w0                                   // Move value to day reg

            cmp     month_r, 1                                  // Check that month input is between 1 and 12
            b.lt    range_err                                   // Otherwise, jump to range_err

            cmp     month_r, 12
            b.gt    range_err

            cmp     day_r, 1                                    // Check that day input is between 1 and 31
            b.lt    range_err                                   // Otherwise, jump to range_err

            cmp     day_r, 31
            b.gt    range_err

// Determine season

season:     adrp    base_r, season_m                            // Calculate base array address
            add     base_r, base_r, :lo12:season_m                     

            // Check if month is an edge case

            cmp     month_r, 3                                  // Edge case for March
            b.eq    mar 
            
            cmp     month_r, 6                                  // Edge case for June
            b.eq    jun 
            
            cmp     month_r, 9                                  // Edge case for September
            b.eq    sep 

            cmp     month_r, 12                                 // Edge case for December
            b.eq    dec 

            // Otherwise, confirm month to find season

            cmp     month_r, 3                                  // If month is less than 3, season is winter
            b.lt    winter 

            cmp     month_r, 6                                  // If month is less than 6, season is spring
            b.lt    spring 

            cmp     month_r, 9                                  // If month is less than 9, season is summer
            b.lt    summer 

            cmp     month_r, 12                                 // If month is less than 12, season is fall
            b.lt    fall 

// Special cases where season depends on the day of the month

mar:        cmp     day_r, 20                                   // March -
            b.le    winter                                      // If day is less than or equal to 20, then season is winter
            b       spring                                      // Otherwise season is spring

jun:        cmp     day_r, 20                                   // June - 
            b.le    spring                                      // If day is less than or equal to 20, then season is spring
            b       summer                                      // Otherwise season is summer

sep:        cmp     day_r, 20                                   // September -
            b.le    summer                                      // If day is less than or equal to 20, then season is summer
            b       fall                                        // Otherwise season is fall   

dec:        cmp     day_r, 20                                   // December -
            b.le    fall                                        // If day is less than or equal to 20, then season is fall
            b       winter                                      // Otherwise season is winter

// Come here once season is confirmed
// Load correct season into x4 to prep for printing

winter:     mov     season_r, 0                                
            ldr     x4, [base_r, season_r, SXTW 3]
            bl      print

spring:     mov     season_r, 1
            ldr     x4, [base_r, season_r, SXTW 3]
            bl      print

summer:     mov     season_r, 2
            ldr     x4, [base_r, season_r, SXTW 3]
            bl      print

fall:       mov     season_r, 3
            ldr     x4, [base_r, season_r, SXTW 3]

// Print function

print:      ldr     x0, =fmt                                    // x0 = fmt for print

            adrp    base_r, month_m                             // Calculate base address for month array
            add     base_r, base_r, :lo12:month_m

            sub     month_r, month_r, 1                         // Subtract 1 from month to calculate index

            ldr     x1, [base_r, month_r, SXTW 3]               // x1 = month for print
            mov     w2, day_r                                   // w2 = day for print


            adrp    base_r, suffix_m                            // Calculate base for suffix array
            add     base_r, base_r, :lo12:suffix_m              

            sub     day_r, day_r, 1                             // Subtract 1 from day to calculate index
            ldr     x3, [base_r, day_r, SXTW 3]                 // x3 = suffix for print

            bl      printf                                      // Print statement

            b       done                                        // Jump to done

// Errors 

range_err:  ldr     x0, =fmt_r_error                            // Jump here if month or day input is out of range
            bl      printf                                      // Print error message
            b       done

error:      ldr     x0, =fmt_error                              // Jump here if arguments is != 2
            bl      printf                                      // Print error message

// End of program

done:       ldp     x29, x30, [sp], 16                          // Exit program
            ret
