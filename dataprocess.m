    clc;
    clear ;
    fileName = "Montage_100_5.xml"; %Change the file address here
    isDraw = 1;
    dom = xmlread(fileName);
    nodes = dom.getElementsByTagName('adag');

    
    node = nodes.item(0);
    jobs = node.getElementsByTagName('job');
    jobLen = (jobs.getLength);
    children = node.getElementsByTagName('child');
    childNum = children.getLength;


    %------------------------Data processing of jobs-----------------------------------%
    %Construct a job structure array
    structSingleJob = struct('jobId',[],'inputSizeArray',{},'inputLen',0,'outputSizeArray',{},'outputLen',0,'runTime',[]);%结构体类型
    structJobs = repmat(structSingleJob,[1 jobLen]); 
    for i=0:jobLen-1
       
        id = string.empty();
        inputSizeArray = string.empty();
        outputSizeArray = string.empty();

         
        jobSingle = jobs.item(i);
        id = char(jobSingle.getAttribute('id'));
        structJobs(i+1).jobId = id;
        runTime = char(jobSingle.getAttribute('runtime'));
        structJobs(i+1).runTime = runTime;



         
        jobI = jobs.item(i);
        uses = jobI.getElementsByTagName('uses');
        usesNum = uses.getLength; 

         
        inputSizes = string.empty();
        outputSizes = string.empty();
        %Initialize, the default value is 0
        structJobs(i+1).inputLen = 0;
        structJobs(i+1).outputLen = 0;
        for j=0:usesNum-1
            usesI = uses.item(j);
            inputOrOutput = (char(usesI.getAttribute('link')));
            if strcmp(inputOrOutput,'input') == 1



                structJobs(i+1).inputLen = structJobs(i+1).inputLen + 1;

                inputSize = (char(usesI.getAttribute('size')));
                inputSizes  = [inputSizes,inputSize];

            else
                structJobs(i+1).outputLen = structJobs(i+1).outputLen + 1;

                outputSize = (char(usesI.getAttribute('size')));
                outputSizes  = [outputSizes,outputSize];

            end

        end
        structJobs(i+1).inputSizeArray = inputSizes;
        structJobs(i+1).outputSizeArray = outputSizes;
    end


    %------------------------Data processing of children-parents-----------------------------------%
    %Construct a structure array for child parent
    structSinglechild = struct('childRef',[],'parentIdArray',{},'parentLen',0);%结构体类型
    structchildren = repmat(structSinglechild,[1 childNum]);%生成结构体数组
    for i=0:childNum-1
       
        ref = string.empty();

        parentArray = string.empty();


       
        childSingle = children.item(i);
        ref = char(childSingle.getAttribute('ref'));
        structchildren(i+1).childRef = ref;


        
        childI = children.item(i);
        parents = childI.getElementsByTagName('parent');
        parentLen = parents.getLength; 

        %Traverse through parents
        parentIdArrays = string.empty();
        structchildren(i+1).parentLen = 0;
        for j=0:parentLen-1
            parentI = parents.item(j);
            parentIdArray = (char( parentI.getAttribute('ref')));

            structchildren(i+1).parentLen = structchildren(i+1).parentLen + 1;
            parentIdArray = (char(parentI.getAttribute('ref')));
            parentIdArrays  = [parentIdArrays,parentIdArray];

        end


        structchildren(i+1).parentIdArray = parentIdArrays;

    end
    disp('Data processing completed!');



    %------------------------Process jobs by converting the corresponding data of numeric strings into numbers---------------%
    structSinglejobLeneral = struct('jobId',[],'inputSizeArray',[],'inputLen',0,'outputSizeArray',[],'outputLen',0,'runTime',[]);%结构体类型
    structJobsNumeral = repmat(structSingleJob,[1 jobLen]); 

    structJobsFirstjobId = structJobs(1).jobId;
    structJobsFirstjobId = strrep(structJobsFirstjobId,'I','0');
    structJobsFirstjobId = strrep(structJobsFirstjobId,'D','0');  
    structJobsFirstjobIdValue = int32((str2double(structJobsFirstjobId)));
    isIdValueOne = (structJobsFirstjobIdValue == 1);  


    for i=1:jobLen
        
        stringTemp = structJobs(i).jobId;
        stringTemp = strrep(stringTemp,'I','0');
        stringTemp = strrep(stringTemp,'D','0');
        if isIdValueOne~=1
            structJobsNumeral(i).jobId = ((str2double(stringTemp))+1);
        else
            structJobsNumeral(i).jobId = ((str2double(stringTemp)));
        end

        structJobsNumeral(i).inputLen = structJobs(i).inputLen;
        structJobsNumeral(i).outputLen = structJobs(i).outputLen;
        structJobsNumeral(i).runTime = ((str2double(structJobs(i).runTime)));

        for j=1:structJobs(i).inputLen
            
            stringTemp = structJobs(i).inputSizeArray(j);
            structJobsNumeral(i).inputSizeArray(j) = ((str2double(stringTemp)));
        end

        for j=1:structJobs(i).outputLen
             
            stringTemp = structJobs(i).outputSizeArray(j);
            structJobsNumeral(i).outputSizeArray(j) = ((str2double(stringTemp)));
        end
    end





 
    structSinglechildNumeral = struct('childRef',[],'parentIdArray',[],'parentLen',0); 
    structchildrenLeneral = repmat(structSinglechildNumeral,[1 childNum]); 

    for i=1:childNum
        stringTemp = structchildren(i).childRef;
        stringTemp = strrep(stringTemp,'I','0');
        stringTemp = strrep(stringTemp,'D','0');  
        if isIdValueOne~=1
            structchildrenLeneral(i).childRef = ((str2double(stringTemp))+1);
        else
            structchildrenLeneral(i).childRef = ((str2double(stringTemp)));
        end

        for j=1:structchildren(i).parentLen
            
            stringTemp = structchildren(i).parentIdArray(j);
            stringTemp = strrep(stringTemp,'I','0');
            stringTemp = strrep(stringTemp,'D','0');  
            if isIdValueOne~=1
                structchildrenLeneral(i).parentIdArray(j) = ((str2double(stringTemp))+1);
            else
                structchildrenLeneral(i).parentIdArray(j) = ((str2double(stringTemp)));
            end

        end
        structchildrenLeneral(i).parentLen = structchildren(i).parentLen;
    end


    structchildrenLeneral2 = repmat(structSinglechildNumeral,[1 jobLen]);%生成结构体数组
    for i=1:jobLen
        structchildrenLeneral2(i).childRef = i;
        structchildrenLeneral2(i).parentLen = 0;
    end

    for i=1:childNum
        structchildrenLeneral2(int32(structchildrenLeneral(i).childRef)) = structchildrenLeneral(i);
    end




    structSingleparentLeneral2 = struct('parentRef',[],'childrenIdArray',[],'childrenLen',0);
    structParentsNumeral2 = repmat(structSingleparentLeneral2,[1 jobLen]);

    for i=1:jobLen
        structParentsNumeral2(i).parentRef = i;
        structParentsNumeral2(i).childrenLen = 0;
    end

    for i=1:childNum
        for j=1:structchildrenLeneral(i).parentLen
            structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).childrenIdArray = [structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).childrenIdArray, (structchildrenLeneral(i).childRef)];
            structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).childrenLen = structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).childrenLen + 1;
            structParentsNumeral2(int32(structchildrenLeneral(i).parentIdArray(j))).parentRef = structchildrenLeneral(i).parentIdArray(j);
        end
    end

    disp('Data conversion to numbers completed！');






    %--------------------------draw figures---------------------------------------------%

     

    JobIDAdjacencyMatrix = zeros(jobLen,jobLen);

    for i=1:childNum
        for j=1:structchildrenLeneral(i).parentLen  
            JobIDAdjacencyMatrix(int32((structchildrenLeneral(i).parentIdArray(j))),int32(structchildrenLeneral(i).childRef)) = 1;
        end
    end
     
    if isDraw == 1
        G = digraph(JobIDAdjacencyMatrix);
        G.plot();
    else
        
    end













    %------------------------------testing--------------------------------%

    taskNum = jobLen;

    structSingleTask = struct('taskId',[],'inputSizeArray',[],'outputSizeArray',[],'childIdArray',[],'childIdArrayLen',0,'parentIdArray',[],'parentIdArrayLen',0,'inputLen',0,'outputLen',0,'taskLayer',0,'runTime',0);%结构体类型
    structTasksBase = repmat(structSingleTask,[1 taskNum]); 





    for i=1:taskNum
        structTasksBase(i).taskId = structJobsNumeral(i).jobId;
        structTasksBase(i).childIdArray = structParentsNumeral2(i).childrenIdArray;
        structTasksBase(i).childIdArrayLen = structParentsNumeral2(i).childrenLen;
        structTasksBase(i).parentIdArray = structchildrenLeneral2(i).parentIdArray;
        structTasksBase(i).parentIdArrayLen = structchildrenLeneral2(i).parentLen; 
        structTasksBase(i).inputSizeArray = structJobsNumeral(i).inputSizeArray;
        structTasksBase(i).inputLen = structJobsNumeral(i).inputLen;
        structTasksBase(i).outputSizeArray = structJobsNumeral(i).outputSizeArray;
        structTasksBase(i).outputLen = structJobsNumeral(i).outputLen;
        structTasksBase(i).runTime = structJobsNumeral(i).runTime;
    end


    
    ancestorTaskArray = [];
    ancestorTaskArrayLen = 0;

    
    for i=1:taskNum
        if structchildrenLeneral2(i).parentLen == 0
            ancestorTaskArrayLen = ancestorTaskArrayLen + 1;
            ancestorTaskArray = [ancestorTaskArray,structchildrenLeneral2(i).childRef];
        end
    end



     
    structTaskLayer = struct('taskId',0,'maxLayer',0,'layers',[]);
    structTaskLayerAll = repmat(structTaskLayer,[1 taskNum]);%生成结构体数组


    for i=1:taskNum
        structTaskLayerAll(i).taskId = i;
    end

     
    for i=1:ancestorTaskArrayLen
        structTaskLayerAll((ancestorTaskArray(i))).layers = [structTaskLayerAll(int32(ancestorTaskArray(i))).layers, 1];
        structTaskLayerAll((ancestorTaskArray(i))).maxLayer = max( structTaskLayerAll(int32(ancestorTaskArray(i))).layers);
        for j=1:structTasksBase(int32(ancestorTaskArray(i))).childIdArrayLen
            structTaskLayerAll(int32(structTasksBase(ancestorTaskArray(i)).childIdArray(j))).layers = [structTaskLayerAll(int32(structTasksBase(ancestorTaskArray(i)).childIdArray(j))).layers,2];
            structTaskLayerAll(int32(structTasksBase(ancestorTaskArray(i)).childIdArray(j))).maxLayer = max(structTaskLayerAll(int32(structTasksBase(ancestorTaskArray(i)).childIdArray(j))).layers);
        end
    end


     

    currentMaxLayerSum = 0;
    lastMaxLayerSum = -1;
    layerMax = 1;  
    while(currentMaxLayerSum ~= lastMaxLayerSum) 
        lastMaxLayerSum = currentMaxLayerSum;
        currentMaxLayerSum = 0;
        for i=1:1:taskNum
            if ismember(i,ancestorTaskArray) == 1

                 
            else
                if structTaskLayerAll(i).maxLayer == 0    
                    continue;
                else
                    for j=1:structTasksBase(i).childIdArrayLen
                        structTaskLayerAll(structTasksBase(i).childIdArray(j)).layers = [structTaskLayerAll(structTasksBase(i).childIdArray(j)).layers , structTaskLayerAll(i).maxLayer+1];
                        structTaskLayerAll(structTasksBase(i).childIdArray(j)).maxLayer = max(structTaskLayerAll(structTasksBase(i).childIdArray(j)).layers);
                        if layerMax < structTaskLayerAll(structTasksBase(i).childIdArray(j)).maxLayer
                            layerMax = structTaskLayerAll(structTasksBase(i).childIdArray(j)).maxLayer;
                        end
                    end
                end
            end
            currentMaxLayerSum = currentMaxLayerSum + structTaskLayerAll(i).maxLayer;
        end  
    end
    disp('Layer calculation completed!');

    for i=1:taskNum
        structTasksBase(i).taskLayer = structTaskLayerAll(i).maxLayer;
    end
    % Generate a structure to store the tasks in each layer
    structLayer = struct('layerIndex',0,'taskArray',[]);
    structLayers = repmat(structLayer,[1 layerMax]); 

    for i=1:layerMax
        structLayers(i).layerIndex = i;
    end
    for i=1:taskNum
        structLayers(structTasksBase(i).taskLayer).taskArray = [structLayers(structTasksBase(i).taskLayer).taskArray,structTasksBase(i).taskId];
    end

    
   
    
    disp('Virtual machine and task initialization data completion!');
    disp('Save Data.....');

    save structTasksBase.mat structTasksBase ;
    save ancestorTaskArray.mat ancestorTaskArray ;
    save structLayers.mat structLayers  ;
    save layerMax.mat layerMax;
    taskLen = jobLen;
    save taskLen.mat taskLen;
    disp('finish!!!');


