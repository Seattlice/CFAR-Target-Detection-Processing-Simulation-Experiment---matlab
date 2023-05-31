clc; clear all;

v1=1;%杂波边缘方差
v2=15;
noise_db1=10;
noise_db2=20;
noise_p1=10.^(noise_db1./10);%噪声功率
noise_p2=10.^(noise_db2./10);
c1=10^(noise_db1/10)+random('Normal',0,v1,1,200);     % 这里是幅度——功率
c2=10^(noise_db2/10)+random('Normal',0,v2,1,200);
xc=[c2,c1];

N=18;%保护单元与参考单元总个数
pro_N=2;%保护单元
PAD=0.2;%虚警概率
k=2.*N./4;
alpha=N.*(PAD.^(-1./N)-1);
index=1+N/2+pro_N/2:length(xc)-N/2-pro_N/2;
XT=zeros(1,length(index));

SNR1=3;    %目标设置
signal1_p=10.^(SNR1./10).*noise_p2;
xc(1,100)=signal1_p;
SNR2=3.5;
signal2_p=10.^(SNR2./10).*noise_p2;
xc(1,105)=signal2_p;
SNR3=3;
signal3_p=10.^(SNR3./10).*noise_p2;
xc(1,110)=signal3_p;

SNR4=2;
signal4_p=10.^(SNR4./10).*noise_p1;
xc(1,260)=signal4_p;
SNR5=4;
signal5_p=10.^(SNR5./10).*noise_p1;
xc(1,265)=signal5_p;
SNR6=2;
signal6_p=10.^(SNR6./10).*noise_p1;
xc(1,270)=signal6_p;


% CA_CFAR
 for i=index
     cell_left=xc(1,i-N/2-pro_N/2:i-pro_N/2-1);
     cell_right=xc(1,i+pro_N/2+1:i+N/2+pro_N/2);
     Z1=(sum(cell_left)+sum(cell_right))./N;%将左右相加之后平均得到Z
     XT1(1,i-N/2-pro_N/2)=Z1.*alpha;%乘以参数alpha即为课本上K0
 end

 % SO_CFAR
 for i=index
     cell_left=xc(1,i-N/2-pro_N/2:i-pro_N/2-1);
     cell_right=xc(1,i+pro_N/2+1:i+N/2+pro_N/2);
     Z2=min([mean(cell_left),mean(cell_right)]);
     XT2(1,i-N/2-pro_N/2)=Z2.*alpha;
 end
 
 % GO_CFAR
 for i=index
     cell_left=xc(1,i-N/2-pro_N/2:i-pro_N/2-1);
     cell_right=xc(1,i+pro_N/2+1:i+N/2+pro_N/2);
     Z3=max([mean(cell_left),mean(cell_right)]);
     XT3(1,i-N/2-pro_N/2)=Z3.*alpha;
 end
 %
figure;
plot(10.*log(abs(xc))./log(10),"LineWidth",1,'Color',[0 0 1]),hold on;%蓝色画出信号
plot(index,10.*log(abs(XT1))./log(10),"LineWidth",1,'Color',[1 0 0]),hold on;
plot(index,10.*log(abs(XT2))./log(10),"LineWidth",1,'Color',[1 1 0]),hold on;
plot(index,10.*log(abs(XT3))./log(10),"LineWidth",1,'Color',[0 0 0]),hold on;
legend("接收信号","CA-CFAR","SO-CFAR","GO-CFAR")
xlabel("距离单元","FontWeight","bold")
ylabel("信号幅度（dB）","FontWeight","bold")
title("杂波边缘多目标仿真结果")
grid on