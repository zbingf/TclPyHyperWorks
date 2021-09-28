*setvalue comps id=3001 propertyid={props 1}
*setvalue comps id=3002 propertyid={props 1}
*setvalue comps id=3003 propertyid={props 1}
*setvalue comps id=3004 propertyid={props 1}
*setvalue comps id=3005 propertyid={props 1}
*setvalue comps id=3006 propertyid={props 1}
*setvalue comps id=3007 propertyid={props 1}
*setvalue comps id=3008 propertyid={props 1}
*setvalue comps id=3009 propertyid={props 1}
*setvalue comps id=30010 propertyid={props 1}
*setvalue comps id=30011 propertyid={props 1}
*setvalue comps id=30012 propertyid={props 1}
*setvalue comps id=30013 propertyid={props 1}
*setvalue comps id=30014 propertyid={props 14}
*setvalue comps id=30015 propertyid={props 14}
*setvalue comps id=30016 propertyid={props 16}
*setvalue comps id=30017 propertyid={props 16}
*setvalue comps id=30018 propertyid={props 16}
*setvalue comps id=30019 propertyid={props 19}

set status [
    catch {
        hm_createmark properties 1 "by id only" "2 3 4 5 6 7 8 9 10 11 12 13 15 17 18"
        *deletemark properties 1 

    } res ]
if {$status} {
    puts "del properties single"


    set status [
        catch {
            *createmark properties 1 2
            *deletemark properties 1  
            #puts "del : name=p2 ; id=2"
        } res ]
    if {$status} {
        puts "del error: name=p2 ; id=2"
    }


    set status [
        catch {
            *createmark properties 1 3
            *deletemark properties 1  
            #puts "del : name=p3 ; id=3"
        } res ]
    if {$status} {
        puts "del error: name=p3 ; id=3"
    }


    set status [
        catch {
            *createmark properties 1 4
            *deletemark properties 1  
            #puts "del : name=p4 ; id=4"
        } res ]
    if {$status} {
        puts "del error: name=p4 ; id=4"
    }


    set status [
        catch {
            *createmark properties 1 5
            *deletemark properties 1  
            #puts "del : name=p5 ; id=5"
        } res ]
    if {$status} {
        puts "del error: name=p5 ; id=5"
    }


    set status [
        catch {
            *createmark properties 1 6
            *deletemark properties 1  
            #puts "del : name=p6 ; id=6"
        } res ]
    if {$status} {
        puts "del error: name=p6 ; id=6"
    }


    set status [
        catch {
            *createmark properties 1 7
            *deletemark properties 1  
            #puts "del : name=p7 ; id=7"
        } res ]
    if {$status} {
        puts "del error: name=p7 ; id=7"
    }


    set status [
        catch {
            *createmark properties 1 8
            *deletemark properties 1  
            #puts "del : name=p8 ; id=8"
        } res ]
    if {$status} {
        puts "del error: name=p8 ; id=8"
    }


    set status [
        catch {
            *createmark properties 1 9
            *deletemark properties 1  
            #puts "del : name=p9 ; id=9"
        } res ]
    if {$status} {
        puts "del error: name=p9 ; id=9"
    }


    set status [
        catch {
            *createmark properties 1 10
            *deletemark properties 1  
            #puts "del : name=p10 ; id=10"
        } res ]
    if {$status} {
        puts "del error: name=p10 ; id=10"
    }


    set status [
        catch {
            *createmark properties 1 11
            *deletemark properties 1  
            #puts "del : name=p11 ; id=11"
        } res ]
    if {$status} {
        puts "del error: name=p11 ; id=11"
    }


    set status [
        catch {
            *createmark properties 1 12
            *deletemark properties 1  
            #puts "del : name=p12 ; id=12"
        } res ]
    if {$status} {
        puts "del error: name=p12 ; id=12"
    }


    set status [
        catch {
            *createmark properties 1 13
            *deletemark properties 1  
            #puts "del : name=p13 ; id=13"
        } res ]
    if {$status} {
        puts "del error: name=p13 ; id=13"
    }


    set status [
        catch {
            *createmark properties 1 15
            *deletemark properties 1  
            #puts "del : name=p15\n _s? a.<>[]/ ; id=15"
        } res ]
    if {$status} {
        puts "del error: name=p15\n _s? a.<>[]/ ; id=15"
    }


    set status [
        catch {
            *createmark properties 1 17
            *deletemark properties 1  
            #puts "del : name=p17 ; id=17"
        } res ]
    if {$status} {
        puts "del error: name=p17 ; id=17"
    }


    set status [
        catch {
            *createmark properties 1 18
            *deletemark properties 1  
            #puts "del : name=p18\n _s? a.<>[]/ ; id=18"
        } res ]
    if {$status} {
        puts "del error: name=p18\n _s? a.<>[]/ ; id=18"
    }

}