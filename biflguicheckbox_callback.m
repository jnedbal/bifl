function biflguicheckbox_callback(gcbo, ~)
global param
global h

if any(h.File == gcbo)
    param.files{2, h.File == gcbo} = get(gcbo, 'Value');
elseif h.PDFs == gcbo
    param.PDFs = get(gcbo, 'Value');
end