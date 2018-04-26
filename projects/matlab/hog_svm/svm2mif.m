function svm2mif(filename, SVMModel, R, C, CellSize, BlockSize, NumBins)
    fp = fopen(filename, 'w');
    BW = 16;% 用4-bit的有符号数来记录
    fprintf(fp, 'DEPTH = %d;\n', 2^ceil(log2((R/CellSize(1)-BlockSize(1)+1)*(C/CellSize(2)-BlockSize(2)+1))));
    fprintf(fp, 'WIDTH = %d;\n', BlockSize(1)*BlockSize(2)*NumBins*BW);  
    fprintf(fp, 'ADDRESS_RADIX = HEX;\n');
    fprintf(fp, 'DATA_RADIX = HEX;\n');
    fprintf(fp, 'CONTENT\n');
    fprintf(fp, 'BEGIN\n');
    feature_size = (BlockSize(1)*BlockSize(2)*NumBins);
    for n=1:floor(size(SVMModel.Beta, 1)/feature_size)
        fprintf(fp, '%X : ', n-1);
        for f=1:feature_size
            beta_nf = (round(2^(BW-2)*SVMModel.Beta((n-1)*feature_size + f, 1)));
            if(beta_nf<0)
                beta_nf = beta_nf + 2^BW;
            end
            beta_nf = uint16(beta_nf);
            fprintf(fp, '%04X', beta_nf);
        end
        fprintf(fp, ';\n');
    end
    
    bias_nf = round(2^(BW-2)*SVMModel.Bias);
    fprintf(fp, '%X : ', n);
    if(bias_nf<0)
        for t=1:(feature_size-4)
            fprintf(fp, 'FF');
        end
        bias_nf = bias_nf + 2^32;
    else
        for t=1:(feature_size-4)
            fprintf(fp, '00');
        end
    end
    fprintf(fp, '%08X;\n', uint32(bias_nf));
    
    fprintf(fp, 'END;\n');
    fclose(fp);
end