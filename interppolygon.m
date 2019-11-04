function varargout = interppolygon(X,N,method)

    [pl bl]         = polygonlength(X);
    orig_metric     = [   0 ;  cumsum(bl/pl) ];
    %X(idx,:)=[];
    % 2. Interpolate
    interp_metric   = ( 0 : 1/(N-1) : 1)';
    Y               = interp1( ...
        orig_metric,...
        X,...
        interp_metric,...
        method);
    
    % 3. Ouputs
    varargout{1} = Y;
    if nargout > 1
        varargout{2} = orig_metric;
    end
    
   
    function varargout = polygonlength(X)
        
        n_dim       = size(X,2);
        delta_X     = 0;
        for dim = 1 : n_dim
            delta_X = delta_X + ...
                diff(X(:,dim)).^2 ;
        end
        
        branch_lengths  = sqrt( delta_X );
%         if n_dim>=6 
%             idx = find(delta_X<3);
%             branch_lengths(idx,:)=[];
%         else
%             idx = find(delta_X>=0);
%         end
        pl              = sum( branch_lengths );
        
        varargout{1}    = pl;
        varargout{2} = branch_lengths;
        %varargout{3} = idx;
       
        
    end

end