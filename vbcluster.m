function List=vbcluster(G,k)
IDX = kmeans(G(:,[2 3 4]),k,'replicates',10,'EmptyAction','drop');
Clength=length(G(1,:));

% obj=gmdistribution.fit(G(:,2:end),k,'Start',IDX,'SharedCov',logical(1));
% label=cluster(obj,G(:,2:end));

[label, model, T] = vbgmm(G(:,[2 3 4])',IDX');
label=label';
G=[G label];
feature=zeros(k,Clength-1);
featurestd=zeros(k,Clength-1);
for i=1:k
     count=length(find(label==i));
     fprintf(['cluster ', num2str(i),':',num2str(count)]);
     for j=2:Clength
     feature(i,j-1)=mean(G(G(:,end)==i,j));
     featurestd(i,j-1)=std(G(G(:,end)==i,j));
     fprintf([' feature ', num2str(j),':',num2str(feature(i,j-1))]);
     end
     fprintf('\n');
end
[C,I]=max(feature(:,end-1));
disp(['Choose Cluster: ', num2str(I)]);
List=G(G(:,end)==I,:);

