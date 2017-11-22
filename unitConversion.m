function [Offset, Gain] = unitConversion_300(Selection, agkName, GTName)
%disp(type(Selection));
switch num2str(Selection)
    case '°C_to_K'
        Offset = 273.15; Gain = 1;
    case 'degC_to_degK'
        Offset = 273.15; Gain = 1; 
    case 'K_to_°C'
        Offset = -273.15; Gain = 1;
    case 'degK_to_degC'
        Offset = -273.15; Gain = 1; 
    case 'hPa_to_bar'
        Offset = 0; Gain = 1/1000;
    case 'bar_to_hPa'
        Offset = 0; Gain = 1000;
    case 'g/min_to_kg/s'
        Offset = 0; Gain = 1/60000;
    case 'kg/s_to_g/min'
        Offset = 0; Gain = 60000;
    case 'kg/h_to_kg/s'
        Offset = 0; Gain = 1/3600; 
    case 'kg/s_to_kg/h'
        Offset = 0; Gain = 3600; 
    case 'km/h_to_m/s'
        Offset = 0; Gain = 1/3.6;
    case 'm/s_to_km/h'
        Offset = 0; Gain = 3.6;
    case 'rpm_to_%'
        Offset = 0; Gain = 1;
    case '%_to_rpm'
        Offset = 0; Gain = 1; 
    case 'deg_to_steps'
        Offset = 0; Gain = 1;
    case 'steps_to_deg'
        Offset = 0; Gain = 1; 
    case 'steps_to_bit'
        Offset = 0; Gain = 1; 
    case 'bit_to_steps'
        Offset = 0; Gain = 1; 
    case 'Others'
        Offset = 999; Gain = 999; 
        disp(['Please check unit conversion between ' agkName ' and ' GTName '.']);
    case 'NoConversionReqd'
        Offset = 0; Gain = 1; 
    otherwise
        Offset = 0; Gain = 1; 
end

 