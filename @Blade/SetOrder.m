function SetOrder(obj)
% This function estimates the Order of the detected Bragg peaks 
% Parameters are:
%
% The function returns:
% The values are saved in the order variable
%
% Copyright & Questions: Laboratory of membrane and protein dynamics, McMaster University,
% Sebastian Himbert (himberts@mcmaster.ca)

  PeakPos  = obj.PeakPosition(:,1);
  PeakInt  = obj.PeakPosition(:,2);
  PeakArea = obj.PeakArea(:,1);
  
  obj.Order = zeros(1,numel(PeakPos));
  obj.Order(1)=1;
  PeakPosCorr(1)  = PeakPos(1);
  PeakIntCorr(1)  = PeakInt(1);
  PeakAreaCorr(1) = PeakArea(1);
  CurOrder = 2;
  for i = 2:1:numel(PeakPos)
      while abs(CurOrder*PeakPos(1)-PeakPos(i))> 0.02
          
        CurOrder = CurOrder + 1;
        obj.Order(CurOrder) = CurOrder;
        PeakPosCorr(CurOrder)  = CurOrder * PeakPos(1);
        PeakIntCorr(CurOrder)  = 0;
        PeakAreaCorr(CurOrder) = 0;
        
        if CurOrder>15
            break
        end
      end
      obj.Order(CurOrder) = CurOrder;
      PeakPosCorr(CurOrder) = PeakPos(i);
      PeakIntCorr(CurOrder) = PeakInt(i);
      PeakAreaCorr(CurOrder) = PeakArea(i);
  end
      PeakInfoCorr(:,1) = PeakPosCorr';
      PeakInfoCorr(:,2) = PeakIntCorr';
      obj.PeakPosition  = PeakInfoCorr;
      obj.PeakArea      = PeakAreaCorr';
end