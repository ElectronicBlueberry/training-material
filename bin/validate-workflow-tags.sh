#!/bin/bash
exit_with=0

#python script to iterate over the steps in the workflow.
function tester { 
    python3 - <<END
import sys 
import json 
with open("$1") as json_file: 
    data = json.load(json_file) 
    if 'tags' not in data or "$2" not in data['tags']: 
        #Checking for 'tags' in workflow
        sys.stderr("Workflow {} has no corresponding 'tags' attribute. Please add:".format(data['name']))
        sys.stderr('"tags": [' + "\n\t" + '"' + "$2" + '"'+ "\n]")
        sys.exit(False)
    elif 'annotation' not in data or not data['annotation']:
        #Checking for 'annotation' in workflow
        sys.stderr("Workflow {} has no corresponding 'annotation' attribute. Please add: \n".format(data['name']))
        sys.stderr('"annotation": "<title of tutorial>"')
        sys.exit(False)
    else:
        #Checking if there are tools used from the testtoolshed
        for stepnr, step in data['steps'].items():
            if step['tool_id'] and step['type'] == 'tool' and 'testtoolshed.g2.bx.psu.edu' in step['tool_id']:
                sys.stderr("Workflow {} has a tool from the testtoolshed in step {}.".format(data['name'], str(stepnr)))
                sys.exit(False)
        sys.exit(True)
END
}

for topicdir in ./topics/*
do
    topic=$(basename $topicdir)
    for tutdir in $topicdir/tutorials/*
    do
        if [ -d $tutdir/workflows/ ];
        then
            for w in $tutdir/workflows/*.ga
            do
                echo "Checking tutorial $w for tags" 
                if tester $w $topic;
                then
		            exit_with=1
                fi
            done
        fi
    done
done

exit $exit_with
