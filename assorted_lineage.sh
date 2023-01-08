#!/bin/bash                                                                                                        
                                                                                                                   
export GITHUB_TOKEN=github_pat_CHANGEME                                                                            
                                                                                                                   
myArray=("taimen" "blueline" "crosshatch" "sargo" "bonito" "flame" "coral" "sunfish" "bramble" "redfin" "barbet" "marlin")                                                                                                            
#myArray=("crosshatch" "sargo" "bonito" "flame" "coral" "sunfish" "bramble" "redfin" "barbet" "marlin")            
RANDOM_DEVICE=${myArray[ $RANDOM % ${#myArray[@]} ]}                                                               
echo $RANDOM_DEVICE                                                                                                
                                                                                                                   
#for LIST_OF_DEVICES in ${myArray[@]}                                                                              
echo "Downloading lineage files"                                                                                   
wget --quiet --wait 2 --random-wait -r -l1 --no-parent --no-directories \
      https://download.lineage.microg.org/$RANDOM_DEVICE/
#done

#create the release/tag if it does not exist
github-release release --user sahlers83 --repo backup_lineageos -t $RANDOM_DEVICE

github-release  info --user sahlers83 \
   --repo backup_lineageos \
   | grep artifact  > current_files_in_github

echo "Renaming lineage files"
for i in `find . -type f \( -iname lineage\*m -o -iname lineage\*.zip -o -iname lineage\*img -o -iname lineage\*256 \) -printf '%f\n'`
do
rename -f 's/\?/./g' "${i}"
done

echo "Listing lineage files"
for i in `find . -type f \( -iname lineage\*m -o -iname lineage\*.zip -o -iname lineage\*img \) -printf '%f\n'`
do
echo $i
  if grep $i current_files_in_github > /dev/null
  then
    echo $i " exists in github"
    rm -f $i
  else
      echo $i " is a new file. So uploading..."
      github-release upload --user sahlers83 \
         --repo backup_lineageos \
         --tag $RANDOM_DEVICE  \
         --file $i --name $i
      rm -fr $i
      sleep 2
   fi
done
