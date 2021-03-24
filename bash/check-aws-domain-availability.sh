#!/bin/bash 
 
# Name: Check for domain name availability 
# linuxconfig.org 
# Please copy, share, redistribute and improve 
 
if [ "$#" == "0" ]; then 
    echo "You need tu supply at least one argument!" 
    exit 1
fi 
 
DOMAINS=( ".com" ".net" ".org" ".com.au" ".co.uk" ".io" ".info" ".co" ".de" ".ca" ".me" ".us" ".eu" ".ac" ".academy" ".accountants" ".adult" ".agency" ".apartments" ".associates" ".auction" ".band" ".bargains" ".be" ".berlin" ".bike" ".bingo" ".biz" ".black" ".blue" ".boutique" ".builders" ".business" ".buzz" ".cab" ".cafe" ".camera" ".camp" ".capital" ".cards" ".care" ".careers" ".cash" ".casino" ".catering" ".cc" ".center" ".ceo" ".ch" ".chat" ".cheap" ".church" ".city" ".claims" ".cleaning" ".click" ".clinic" ".clothing" ".cloud" ".club" ".co.nz" ".co.za" ".coach" ".codes" ".coffee" ".college" ".com.mx" ".community" ".company" ".computer" ".condos" ".construction" ".consulting" ".contractors" ".cool" ".coupons" ".credit" ".creditcard" ".cruises" ".cz" ".dance" ".dating" ".deals" ".delivery" ".democrat" ".dental" ".diamonds" ".digital" ".direct" ".directory" ".discount" ".dog" ".domains" ".education" ".email" ".energy" ".engineering" ".enterprises" ".equipment" ".es" ".estate" ".events" ".exchange" ".expert" ".exposed" ".express" ".fail" ".farm" ".fi" ".finance" ".financial" ".fish" ".fitness" ".flights" ".florist" ".fm" ".football" ".forsale" ".foundation" ".fr" ".fund" ".furniture" ".futbol" ".fyi" ".gallery" ".gg" ".gift" ".gifts" ".glass" ".global" ".gold" ".golf" ".graphics" ".gratis" ".green" ".gripe" ".guide" ".guru" ".haus" ".healthcare" ".help" ".hiv" ".hockey" ".holdings" ".holiday" ".host" ".house" ".im" ".immo" ".immobilien" ".in" ".industries" ".ink" ".institute" ".insure" ".international" ".investments" ".irish" ".it" ".jewelry" ".jp" ".kaufen" ".kim" ".kitchen" ".kiwi" ".land" ".lease" ".legal" ".lgbt" ".life" ".lighting" ".limited" ".limo" ".link" ".live" ".loan" ".loans" ".lol" ".maison" ".management" ".marketing" ".mba" ".me.uk" ".media" ".memorial" ".mobi" ".moda" ".money" ".mortgage" ".movie" ".mx" ".name" ".net.au" ".net.nz" ".network" ".news" ".ninja" ".nl" ".onl" ".online" ".org.nz" ".org.uk" ".partners" ".parts" ".photo" ".photography" ".photos" ".pics" ".pictures" ".pink" ".pizza" ".place" ".plumbing" ".plus" ".poker" ".porn" ".pro" ".productions" ".properties" ".pub" ".qpon" ".recipes" ".red" ".reise" ".reisen" ".rentals" ".repair" ".report" ".republican" ".restaurant" ".reviews" ".rip" ".rocks" ".ruhr" ".run" ".sale" ".sarl" ".school" ".schule" ".se" ".services" ".sex" ".sexy" ".sh" ".shiksha" ".shoes" ".show" ".singles" ".soccer" ".social" ".solar" ".solutions" ".studio" ".style" ".sucks" ".supplies" ".supply" ".support" ".surgery" ".systems" ".tattoo" ".tax" ".taxi" ".team" ".technology" ".tennis" ".theater" ".tienda" ".tips" ".tires" ".today" ".tools" ".tours" ".town" ".toys" ".trade" ".training" ".tv" ".uk" ".university" ".uno" ".vacations" ".vc" ".vegas" ".ventures" ".vg" ".viajes" ".video" ".villas" ".vision" ".voyage" ".watch" ".website" ".wien" ".wiki" ".works" ".world" ".wtf" ".xyz" ".zone" )

ELEMENTS=${#DOMAINS[@]} 

while (( "$#" )); do 
  for (( i=0;i<$ELEMENTS;i++)); do 
    whois $1${DOMAINS[${i}]} | egrep -q '^No match|^NOT FOUND|^Not fo|AVAILABLE|^No Data Fou|has not been regi|No entri' 
	  if [ $? -eq 0 ]; then 
	      echo "$1${DOMAINS[${i}]} : available" 
	  fi 
  done 
  shift 
done
