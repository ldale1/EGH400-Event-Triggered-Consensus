classdef RefClass < handle
    % This is to be a middleman between the handle class
    % and what is being subclassed to encapsulate out
    % the unwanted methods
    
    properties
    end

    methods 
        function obj = RefClass()
            % Class
        end

        % Don't want any of the following classes in 
        function varargout = findobj(O,varargin)
            % -
            varargout = findobj@handle(O,varargin);
        end
        function varargout = findprop(O,varargin)
            % -
            varargout = findprop@handle(O,varargin);
        end
        function varargout = addlistener(O,varargin)
            % -
            varargout = addlistener@handle(O,varargin);
        end
        function varargout = notify(O,varargin)
            % -
            varargout = notify@handle(O,varargin);
        end
        function varargout = listener(O,varargin)
            % -
            varargout = listener@handle(O,varargin);
        end
        function varargout = delete(O,varargin)
            % -
            varargout = delete@handle(O,varargin);
        end
        function varargout = gt(O,varargin)
            % -
            varargout = gt@handle(O,varargin);
        end
        function varargout = lt(O,varargin)
            % -
            varargout = lt@handle(O,varargin);
        end
        function varargout = ge(O,varargin)
            % -
            varargout = ge@handle(O,varargin);
        end
        function varargout = le(O,varargin)
            % -
            varargout = le@handle(O,varargin);
        end
        function varargout = eq(O,varargin)
            % -
            varargout = eq@handle(O,varargin);
        end
        function varargout = ne(O,varargin)
            % -
            varargout = ne@handle(O,varargin);
        end
    end
        
end