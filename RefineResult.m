function [List,NL]=RefineResult(G,L,similarity)
Clength=length(G(1,:));
U=G;
t=0;
lowbound=0.8;
upbound=0.98;
SelectFeatures=[2 3 4];
if nargin<3
    for i=lowbound:0.01:upbound
        similarity=i;
        t=t+1;
        INTVAL=[0.5-similarity/2,0.5+similarity/2];
        G=U;
        for j=1:length(SelectFeatures)
            inttmp=norminv(INTVAL,mean(G(:,SelectFeatures(j))),std(G(:,SelectFeatures(j))));
            G(G(:,SelectFeatures(j))<inttmp(1),:)=[];
            G(G(:,SelectFeatures(j))>inttmp(2),:)=[];
        end
        count(t)=length(G(:,1));
         %disp([' Count: ', num2str(count(t)),' Similarity: ', num2str(similarity)]);
    end
    
    for i=1:t-1
        delcount(i)=(count(i+1)-count(i))./count(i);
        disp([' Ratio: ',num2str(i), '-',num2str(count(i+1)), '-',num2str(delcount(i))]);
%         if delcount(i)<0.02;
%             disp([' Selected: ', num2str(i+1)]);
%             similarity=lowbound-0.01+0.01*(i+1);
%             disp([' Similarity: ', num2str(similarity)]);
%             break;
%         end
    end
    for j=1:i-1
        ddel(j)=(delcount(j+1)-delcount(j))./delcount(j);
        %disp([' Ratio: ',num2str(j), '-',num2str(delcount(j+1)), '-',num2str(ddel(j))]);
%         if delcount(i)<0.02;
%             disp([' Selected: ', num2str(i+1)]);
%             similarity=lowbound-0.01+0.01*(i+1);
%             disp([' Similarity: ', num2str(similarity)]);
%             break;
%         end
    end
    
    [C,I]=min((delcount));
    disp([' Selected: ',num2str(I+1)]);
    similarity=lowbound-0.01+0.01*(I+1);
end
 disp([' Similarity: ', num2str(similarity)]);
INTVAL=[0.5-similarity/2,0.5+similarity/2];
        List=U;
        for j=1:length(SelectFeatures)
            inttmp=norminv(INTVAL,mean(List(:,SelectFeatures(j))),std(List(:,SelectFeatures(j))));
            List(List(:,SelectFeatures(j))<inttmp(1),:)=[];
            List(List(:,SelectFeatures(j))>inttmp(2),:)=[];
        end
        disp(['Final Count: ', num2str(length(List(:,1))),' with TOP ', num2str(similarity*100),'% candidates' ]);
        %List(List(:,4)>10,:)=[];
it=ismember(L(:),List(:,1));
NL=it.*L(:);
NL=reshape(NL,size(L));
       
        