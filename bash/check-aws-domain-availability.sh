#!/bin/bash 
 
# Name: Check for domain name availability 
# linuxconfig.org 
# Please copy, share, redistribute and improve 
 
if [ "$#" == "0" ]; then 
    echo "You need tu supply at least one argument!" 
    exit 1
fi 
 
DOMAINS=( '.ac' '.academy' '.accountants' '.adult' '.agency' '.apartments' '.associates' '.auction' '.audio' '.band' '.bargains' '.bike' '.bingo' '.biz' '.black' '.blue' '.boutique' '.builders' '.business' '.buzz' '.cab' '.cafe' '.camera' '.camp' '.capital' '.cards' '.care' '.careers' '.cash' '.casino' '.catering' '.cc' '.center' '.ceo' '.chat' '.cheap' '.church' '.city' '.claims' '.cleaning' '.click' '.clinic' '.clothing' '.cloud' '.club' '.coach' '.codes' '.coffee' '.college' '.com' '.community' '.company' '.computer' '.condos' '.construction' '.consulting' '.contractors' '.cool' '.coupons' '.credit' '.creditcard' '.cruises' '.dance' '.dating' '.deals' '.delivery' '.democrat' '.dental' '.diamonds' '.diet' '.digital' '.direct' '.directory' '.discount' '.dog' '.domains' '.education' '.email' '.energy' '.engineering' '.enterprises' '.equipment' '.estate' '.events' '.exchange' '.expert' '.exposed' '.express' '.fail' '.farm' '.finance' '.financial' '.fish' '.fitness' '.flights' '.florist' '.flowers' '.fm' '.football' '.forsale' '.foundation' '.fund' '.furniture' '.futbol' '.fyi' '.gallery' '.gift' '.gifts' '.glass' '.global' '.gold' '.golf' '.graphics' '.gratis' '.green' '.gripe' '.guide' '.guitars' '.guru' '.haus' '.healthcare' '.help' '.hiv' '.hockey' '.holdings' '.holiday' '.host' '.hosting' '.house' '.im' '.immo' '.immobilien' '.industries' '.info' '.ink' '.institute' '.insure' '.international' '.investments' '.io' '.irish' '.jewelry' '.juegos' '.kaufen' '.kim' '.kitchen' '.kiwi' '.land' '.lease' '.legal' '.lgbt' '.life' '.lighting' '.limited' '.limo' '.link' '.live' '.loan' '.loans' '.lol' '.maison' '.management' '.marketing' '.mba' '.media' '.memorial' '.mobi' '.moda' '.money' '.mortgage' '.movie' '.name' '.net' '.network' '.news' '.ninja' '.onl' '.online' '.org' '.partners' '.parts' '.photo' '.photography' '.photos' '.pics' '.pictures' '.pink' '.pizza' '.place' '.plumbing' '.plus' '.poker' '.porn' '.pro' '.productions' '.properties' '.property' '.pub' '.qpon' '.recipes' '.red' '.reise' '.reisen' '.rentals' '.repair' '.report' '.republican' '.restaurant' '.reviews' '.rip' '.rocks' '.run' '.sale' '.sarl' '.school' '.schule' '.services' '.sex' '.sexy' '.shiksha' '.shoes' '.show' '.singles' '.soccer' '.social' '.solar' '.solutions' '.studio' '.style' '.sucks' '.supplies' '.supply' '.support' '.surgery' '.systems' '.tattoo' '.tax' '.taxi' '.team' '.technology' '.tennis' '.theater' '.tienda' '.tips' '.tires' '.today' '.tools' '.tours' '.town' '.toys' '.trade' '.training' '.tv' '.university' '.uno' '.vacations' '.vegas' '.ventures' '.vg' '.viajes' '.video' '.villas' '.vision' '.voyage' '.watch' '.website' '.wiki' '.works' '.world' '.wtf' '.xyz' '.zone' '.ac' '.co.za' '.sh' '.ca' '.cl' '.co' '.com.ar' '.com.br' '.com.mx' '.mx' '.us' '.vc' '.vg' '.cc' '.co.nz' '.com.au' '.com.sg' '.fm' '.in' '.jp' '.io' '.net.au' '.net.nz' '.org.nz' '.qa' '.ru' '.sg' '.be' '.berlin' '.ch' '.co.uk' '.de' '.es' '.eu' '.fi' '.fr' '.gg' '.im' '.it' '.me' '.me.uk' '.nl' '.org.uk' '.ruhr' '.se' '.uk' '.wien' )

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
