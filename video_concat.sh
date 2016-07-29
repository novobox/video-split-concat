#!/bin/bash
#source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/include/lib/oo-bootstrap.sh" || echo "Please run install `video_concat.sh install`"




PATH_DIRECTORY=$(cd `dirname $0` && pwd)

#NEED TO HAVE FFMPEG INSTALLED
#to install this lib, do
#sudo apt-get install libav-tools
#sudo add-apt-repository ppa:mc3man/trusty-media
#sudo apt-get update
#sudo apt-get install ffmpeg gstreamer0.10-ffmpeg

_usage(){
  grep "^[^_].\+(){$" $0 | while read line; do
    local cmd=$(echo "$line" | sed "s/(){//g")
    local info=$(grep -C0 -A0 -B1 "$cmd(){" $0 | sed "N;s/\n.*//g" )
    printf "    $0 %-20s %-40s\n" "$cmd ($info)" | grep "#"
  done; echo "";
}

_php_get_end_time(){
    local time_start=$1
    local time_end=$2
    phpcode='
    date_default_timezone_set("UTC");
    $time_start_array = explode(":","'$time_start'");
    $time_end_array = explode(":","'$time_end'");

    $time_start = mktime($time_start_array[0],$time_start_array[1],$time_start_array[2]);
    $time_end = mktime($time_end_array[0],$time_end_array[1],$time_end_array[2]);

    $time_duration = $time_end-$time_start;
    $times_up = date("H:i:s",$time_duration);    

    echo $times_up;
    '
    echo $phpcode
}

#Installation before running script
#install(){
#}

#./ init directory (initialize a directory before adding videos and config, and before running)
init(){

    dossier_video=$1

    CURRENT=$(pwd)
    if [ ! -d $dossier_video ];then
        if [ ! -L "$LINK_OR_DIR" ]; then
            # And no is a symlink!
            # (Symbolic link is specific)
            mkdir $dossier_video
        fi
    fi
    echo "GO to directory "$dossier_video
    cd $dossier_video
    echo "- Put videos in videos_input directory
- Put your config in a file (same as sample_config.txt)
- Define config in your file
- Execute ./video_concat run path/to/directory your_file.txt name_output_video.mp4
- Get your vid in output directory
" > readme.txt
    mkdir videos_input
    mkdir tmp_list_splitted_videos
    mkdir output
    echo "

video_01.mp4 00:00:00 00:00:15
video_02.mp4 00:15:56 00:21:20
video_01.mp4 00:24:13 00:36:12
etc.. (Note laissez la premiere ligne vide (sais pas pk :/)
" > sample_config.txt
    echo "Return to current directory"
    cd $CURRENT

}


#./ run directory config.txt name_video.mp4 (./video_concat run directory config name_video)
run(){

    dossier_video=$1
    config_file=$2
    name_output_video=$3

    CURRENT=$(pwd)
    count=0
    echo "GO to directory "$dossier_video
    cd $dossier_video
    #split videos in temporary dir


    arrex=""

    rm tmp_list_splitted_videos/*

    echo "" > tmp_list_splitted_videos/gen_vids.sh
    echo "" > tmp_list_splitted_videos/concat.txt

    while read video start end; do 

        count=$((count+1));
        
        #ffmpeg -i videos_input/$video -ss $start -t $time -c copy tmp_list_splitted_videos/$count$name_output_video;
        
        #echo "ffmpeg -i videos_input/"$video" -ss "$start" -to "$end" -async 1 tmp_list_splitted_videos/"$count$name_output_video"
        if [ ! -z "$video" ]; then

            #On va start la video à $start en lecture et non en ecriture pour éviter de lire toute une partie de la video pour en extraire qu'une partie.
            #$end par contre doit être recalculé car la video en sortie est plus courte d'une durée de $start
            code=$(_php_get_end_time $start $end)
            time_end=$(php -r "$code")

            echo "ffmpeg -ss "$start" -i videos_input/"$video" -to "$time_end" -async 1 tmp_list_splitted_videos/"$count$name_output_video"
sleep 1
" >> tmp_list_splitted_videos/gen_vids.sh
            echo "file '"$count$name_output_video"'" >> tmp_list_splitted_videos/concat.txt

        fi


    done < $config_file

    chmod +x tmp_list_splitted_videos/gen_vids.sh
    tmp_list_splitted_videos/gen_vids.sh


    #while read video start time; do 
    #    ffmpeg -i videos_input/$video -ss $start -t $time -c copy tmp_list_splitted_videos/$count$name_output_video;
    #    echo "ffmpeg -i videos_input/"$video" -ss "$start" -t "$time" -c copy tmp_list_splitted_videos/"$count$name_output_video; 
    #    count=$((count+1));
    #done < $config_file

    #while read vidname start time;do echo "ffmpeg -i videos_input/"$vidname" -ss "$start" -t "$time" -c copy tmp_list_splitted_videos/"$count$name_output_video;ffmpeg -i videos_input/$vidname -ss $time -t 10 -c copy tmp_list_splitted_videos/$count$name_output_video;count=$((count+1));done < $config_file
    
    #CONCATENATE ALL VIDS
    
    ffmpeg -f concat -i tmp_list_splitted_videos/concat.txt -c copy output/$name_output_video


    echo "Generated video : output/"$name_output_video
    cd $CURRENT

}

"$@"
if [ ${#1} == 0 ]; then echo "$CMDS" | echo "Usage: "; _usage; fi
