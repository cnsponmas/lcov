#!/usr/bin/env bash

#instrument program flow＝yes
#generate legacy test coverage files＝yes

#info里设置：application does not run in background＝yes。
#application supportsitunesfiles sharing=yes

outputpath='./cover_output'
exit_file_name=('SSKeychain*')

function usage() {
        echo "USAGE:"
        echo "  cover [-h] [-v] [-p <projectpath>] [-s <schemename>] [-o <outdirname>] "
        exit 1
}

function initDir(){
    rm $outputpath
    mkdir $outputpath
    mkdir $outputpath/tmp
}

function xcodesetting() {
    initDir
    project_setting=$(xcodebuild -showBuildSettings -scheme $scheme_name -project $projectpath -json)
    echo $project_setting | jq -r '.[0].buildSettings.PROJECT_TEMP_DIR' > $outputpath/setting.txt
    project_setting_out=`cat $outputpath/setting.txt`
    detail_path="Debug-iphonesimulator/$scheme_name.build/Objects-normal/x86_64"
    project_output_dir=$project_setting_out/$detail_path
    echo $project_output_dir

    outputCoverReport
}

function clearDir(){
    rm -f $outputpath/setting.txt
    rm -f $outputpath/coverage.info
    rm -fR $outputpath/tmp
}

function outputCoverReport(){    
    cp $project_output_dir/*.gcno $outputpath/tmp
    cp $project_output_dir/*.gcda $outputpath/tmp

    for file_name in ${exit_file_name[@]};do
        echo $file_name
        rm $outputpath/tmp/$file_name
    done
    echo 'output'

    project_dir=$(pwd)

    lcov -c -d $outputpath/tmp -b $project_dir -o $outputpath/coverage.info

    genhtml -t 单元测试报告 $outputpath/coverage.info -o $outputpath

    clearDir
    # open $outputpath
    exit
}

while getopts :vhp:s:o: opt
do
    case "$opt" in
        o)
            path=$OPTARG
            outputpath=./$path
            ;;
        p)
			projectpath=$OPTARG
            echo "  project path:" $projectpath            
            ;;
        s)
            scheme_name=$OPTARG
            echo "  scheme_name:" $scheme_name
            ;;
		v)
			echo "  version:1.0.0"
			exit
			;;
        # 匹配其他选项
        ?)
            usage
            ;;
        esac
done

xcodesetting 
