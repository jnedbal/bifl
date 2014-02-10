function biflguiradio_callback(gcbo, ~)
global h
global param

if h.pumpRadio(1) == gcbo
    set(h.pumpRadio(h.pumpRadio > 0), 'Value', 0);
    set(gcbo, 'Value', 1);
    param.pumpString = get(gcbo, 'String');
    param.pumpTag = get(gcbo, 'Tag');
    return
end

switch gcbo
    case num2cell(h.pumpRadio)
        set(h.pumpRadio(h.pumpRadio ~= 0), 'Value', 0);
        set(gcbo, 'Value', 1);
        param.pumpString = get(gcbo, 'String');
        param.pumpTag = get(gcbo, 'Tag');
end