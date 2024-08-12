# VSD_CNN_accelerator
## System architecture
### NN architecture
* NIN model structure
  * We use NIN to improve the accurancy of detection with less parameter needed,
  * model structure :
   ![image](https://github.com/user-attachments/assets/7783b0c6-9e93-4c0e-8ee4-49047fa08078)
* Dataset
  * Source : GTSRB - German Traffic sign recognition ([kaggle](https://www.kaggle.com/datasets/meowmeowmeowmeowmeow/gtsrb-german-traffic-sign "link"))
  * Number of classes: 43 (Traffic sign)
  * Train : $Total = 34799 imgs$
  * Test : $Total = 12630 imgs$
  * Image size: $32*32$ pixels
* Clip-Q
  * Clip-Q is used to save the usage of Mem
  * Clip-Q Step :
  ![image](https://user-images.githubusercontent.com/73687292/215978048-e9390e57-0a71-429e-a343-7c77aa3f31b5.png)
  * Clip-Q example :
  ![image](https://user-images.githubusercontent.com/73687292/215978230-d5813d08-4d2b-4f5b-bf23-803b62f18b0e.png)
* Final Accuracy = 80.6%
### HW architecture
* The HW component's details
* ![image](https://github.com/user-attachments/assets/67fcbea5-3f4d-408f-8d83-21a1417af9f4)

### EPU architecture
* EPU structure
  * Weight  buffer(180KB)
  * Bias buffer(2KB)
  * Input buffer(384KB)
  * Output buffer(384KB)

* EPU mode
  * Conv3x3
  * 4PE,each with 9 MACs
  * Relu
  * Max pooling
  * Conv3x3
  * 4PE,each with 9 MACs
  * Relu
  * Max pooling
  * Flatten
  * Fully Connected

![image](https://github.com/user-attachments/assets/6fffc05d-4ca4-4e8a-af3a-83af044ac074)


## Verification
### EPU verification
1. Stand-alone testbench for EPU
2. TB loads input/weight/bias data into RTL-simulated SRAM buffers.
3. TB pulls start signal to high
4. EPU starts computation and writes results to output buffer.
5. EPU pulls finish signal to high
6. TB verify the content of output buffer.

![image](https://github.com/user-attachments/assets/684a2020-d904-496a-ad45-51533699f0f0)

### Full sys verification
1. Assume ALL input/weight/bias data in DRAM.
2. CPU runs booting program with DMA.
3. Use DMA to move data from DRAM to EPU’s buffer.
4. CPU writes to EPU ctrl registersand starts EPU to computation.
5. 8-bit weight shared by that layer “start” signal.
6. EPU writes to output buffer as CPU stuck at WFI.
7. EPU finishes and send interrupt. CPU continues with ISR(Interrupt service routine).
8. CPU writes ctrl signals for next layer.
9. Trigger “In-Output buffer swap”
10. Output of this layer is the input of next layer
11. Use DMA move new weight/bias/parameter data of next layer.
12. If done, DMA move data from EPU to DRAM.
13. TB verifies the maximum content of DRAM as the EPU's predicted result and compares it with golden.

## Overall results
![image](https://github.com/user-attachments/assets/e6344a66-7470-4526-817f-2b5d03624d96)
![image](https://github.com/user-attachments/assets/f6f800e3-fb4d-4748-891d-d8baf8f9ca53)


## Contribution
Thanks to 陳燦仁 林晉宇 張正德 柯岳宏 蔡硯安 to complete this project.
 
