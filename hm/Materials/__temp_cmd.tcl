*setvalue comps id=30014 propertyid={props 14}
*setvalue comps id=30015 propertyid={props 14}
*setvalue comps id=30016 propertyid={props 16}
*setvalue comps id=30017 propertyid={props 17}
*setvalue comps id=30018 propertyid={props 17}
*setvalue comps id=30019 propertyid={props 19}

set status [
    catch {
        hm_createmark properties 1 "by id only" "15 18"
        *deletemark properties 1 

    } res ]
if {$status} {
    puts "del properties single"


    set status [
        catch {
            *createmark properties 1 15
            *deletemark properties 1  
            #puts "del : name=p15 ; id=15"
        } res ]
    if {$status} {
        puts "del error: name=p15 ; id=15"
    }


    set status [
        catch {
            *createmark properties 1 18
            *deletemark properties 1  
            #puts "del : name=p18 ; id=18"
        } res ]
    if {$status} {
        puts "del error: name=p18 ; id=18"
    }

}