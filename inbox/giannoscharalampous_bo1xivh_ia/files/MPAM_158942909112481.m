close all; clear; clc

%orismos twn timwn pou dinei i ekfonisi
Tsample=1;
Tc=4;
Tsymbol=40;
Eb=1/2;
fc=1/Tc;
gpulse = sqrt(2/Tsymbol);

%oi periptwseis pou mporei na prokypsoun - times gia M, A, graycode flag
cases=[2,1,0; 4,1/sqrt(5),0; 4,1/sqrt(5),1; 8,1/sqrt(21),0; 8,1/sqrt(21),1;
16,1/sqrt(85),0; 16,1/sqrt(85),1];

for n=1:7
    %arxikopoihsh twn timwn symfwna me thn kathe periptwsh
    M=cases(n,1);
    A=cases(n,2);
    gc=cases(n,3);
    
    %orismos twn diadikwn psifiwn pou theloume na paragoume
    Lb=10000*log2(M);
    xbits=randsrc(Lb,1,[0 1]);
    insignal=reshape(xbits,Lb/log2(M),log2(M));
    
    %arxikopoihsh eksodou
    outsignal=insignal*0;
    ybits=xbits*0;
    
    N=Lb/log2(M);   %mhkos
    
    %shma eksodou
    s1=zeros(Lb/log2(M)*40,1); %akolouthei th morfh pou dothike gia ton thoryvo

    %symvola 
    %xwris gray code
    if(gc==0 && M==2)
        symbols=[0 ; 1];
    end
    if(gc==0 && M==4)
        symbols=[0 0 ; 0 1 ; 1 0 ; 1 1];
    end
    if(gc==0 && M==8)
        symbols=[0 0 0 ; 0 0 1 ; 0 1 0 ; 0 1 1; 1 0 0 ; 1 0 1 ; 1 1 0; 1 1 1 ];
    end
    if(gc==0 && M==16)
        symbols=[0 0 0 0 ; 0 0 0 1 ; 0 0 1 0 ; 0 0 1 1; 0 1 0 0 ; 0 1 0 1 ; 0 1 1 0; 0 1 1 1; 1 0 0 0;
        1 0 0 1 ; 1 0 1 0 ; 1 0 1 1; 1 1 0 0 ; 1 1 0 1 ; 1 1 1 0; 1 1 1 1];
    end

    %me gray code
    if(gc==1 && M==4)
        symbols=[0 0 ; 0 1 ; 1 1 ; 1 0];
    end
    if(gc==1 && M==8)
        symbols=[0 0 0 ; 0 0 1 ; 0 1 1 ; 0 1 0; 1 1 0 ; 1 1 1 ; 1 0 1; 1 0 0 ];
    end
    if(gc==1 && M==16)
        symbols=[0 0 0 0 ; 0 0 0 1 ; 0 0 1 1 ; 0 0 1 0; 0 1 1 0 ; 0 1 1 1 ; 0 1 0 1; 0 1 0 0; 1 1 0 0;
        1 1 0 1; 1 1 1 1; 1 1 1 0; 1 0 1 0; 1 0 1 1; 1 0 0 1; 1 0 0 0];
    end

    snrcount=1;%metra to snr pou eimaste wste na ftiaxei tous pinakes ber, ser

    for snr=0:5:40
        k=1;
        %PAM diamorfosi
        for i=1:N
        %vriskoume to m pou antistoixei se kathe symbolo
            for j=1:M
                if (sum(insignal(i,:)==symbols(j,:))==log2(M))
                    m=j;
                end
            end
        %ypologismos tis ekpempomenis seiras s(t)
            for t=0:Tsymbol-1
            s1(k)=(2*m-1-M)*A*gpulse*cos(2*pi*fc*t);
            k=k+1;
            end
        end
        
    %ypologismos thoryvoy kai prosthesi toy
    No=Eb/(10^(snr/10));
    noise = sqrt(No/2)*randn(N*40,1);
    r=noise+s1;
    
    %PAM apodiamorfosi
    k=1;
    for i=1:N
    %ypologismos tou kathe symbolou
        for t=0:Tsymbol-1
            rr(t+1)=r(k)*gpulse*cos(2*pi*fc*t);
            k=k+1;
        end
        rsymbol=sum(rr);
    %apostasi kathe symvolou
        for m=1:M
            sm=(2*m-1-M)*A;
            dist(m)=sqrt(sum((rsymbol-sm).^2));
        end
    %demaper
        [mnm ,l]=min(dist);
        outsignal(i,:)=symbols(l,:);
    end
    %ypologismos tou ber kai ser gia kathe snr 
    ybits=outsignal(:);
    ber(n,snrcount)=sum(abs(ybits-xbits))/Lb;
    ser(n,snrcount)=sum(abs(bi2de(outsignal)-bi2de(insignal)))/N;

    snrcount=snrcount+1;
    end
end
ser(1,:)=[]; %den theloume to 2pam sto ser

%provoli tou grafimatos
figure(1)
snr=0:5:40;
semilogy(snr,ber,'s-');
xlabel('SNR');
ylabel('BER');
legend ({'2-PAM','4-PAM','4-PAM gc','8-PAM','8-PAM gc','16-PAM','16-PAM gc'},'Location','southwest','NumColumns',2)
figure(2)
snr=0:5:40;
semilogy(snr,ser,'^-');
xlabel('SNR');
ylabel('SER');
legend ({'4-PAM','4-PAM gc','8-PAM','8-PAM gc','16-PAM','16-PAM gc'},'Location','southwest','NumColumns',2)





