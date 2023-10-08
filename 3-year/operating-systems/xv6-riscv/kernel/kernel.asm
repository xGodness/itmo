
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	a1010113          	addi	sp,sp,-1520 # 80008a10 <stack0>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	88070713          	addi	a4,a4,-1920 # 800088d0 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	ade78793          	addi	a5,a5,-1314 # 80005b40 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdcabf>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dc678793          	addi	a5,a5,-570 # 80000e72 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	382080e7          	jalr	898(ra) # 800024ac <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	780080e7          	jalr	1920(ra) # 800008ba <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	711d                	addi	sp,sp,-96
    80000166:	ec86                	sd	ra,88(sp)
    80000168:	e8a2                	sd	s0,80(sp)
    8000016a:	e4a6                	sd	s1,72(sp)
    8000016c:	e0ca                	sd	s2,64(sp)
    8000016e:	fc4e                	sd	s3,56(sp)
    80000170:	f852                	sd	s4,48(sp)
    80000172:	f456                	sd	s5,40(sp)
    80000174:	f05a                	sd	s6,32(sp)
    80000176:	ec5e                	sd	s7,24(sp)
    80000178:	1080                	addi	s0,sp,96
    8000017a:	8aaa                	mv	s5,a0
    8000017c:	8a2e                	mv	s4,a1
    8000017e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000180:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000184:	00011517          	auipc	a0,0x11
    80000188:	88c50513          	addi	a0,a0,-1908 # 80010a10 <cons>
    8000018c:	00001097          	auipc	ra,0x1
    80000190:	a46080e7          	jalr	-1466(ra) # 80000bd2 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000194:	00011497          	auipc	s1,0x11
    80000198:	87c48493          	addi	s1,s1,-1924 # 80010a10 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    8000019c:	00011917          	auipc	s2,0x11
    800001a0:	90c90913          	addi	s2,s2,-1780 # 80010aa8 <cons+0x98>
  while(n > 0){
    800001a4:	09305263          	blez	s3,80000228 <consoleread+0xc4>
    while(cons.r == cons.w){
    800001a8:	0984a783          	lw	a5,152(s1)
    800001ac:	09c4a703          	lw	a4,156(s1)
    800001b0:	02f71763          	bne	a4,a5,800001de <consoleread+0x7a>
      if(killed(myproc())){
    800001b4:	00001097          	auipc	ra,0x1
    800001b8:	7f2080e7          	jalr	2034(ra) # 800019a6 <myproc>
    800001bc:	00002097          	auipc	ra,0x2
    800001c0:	13a080e7          	jalr	314(ra) # 800022f6 <killed>
    800001c4:	ed2d                	bnez	a0,8000023e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800001c6:	85a6                	mv	a1,s1
    800001c8:	854a                	mv	a0,s2
    800001ca:	00002097          	auipc	ra,0x2
    800001ce:	e84080e7          	jalr	-380(ra) # 8000204e <sleep>
    while(cons.r == cons.w){
    800001d2:	0984a783          	lw	a5,152(s1)
    800001d6:	09c4a703          	lw	a4,156(s1)
    800001da:	fcf70de3          	beq	a4,a5,800001b4 <consoleread+0x50>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001de:	00011717          	auipc	a4,0x11
    800001e2:	83270713          	addi	a4,a4,-1998 # 80010a10 <cons>
    800001e6:	0017869b          	addiw	a3,a5,1
    800001ea:	08d72c23          	sw	a3,152(a4)
    800001ee:	07f7f693          	andi	a3,a5,127
    800001f2:	9736                	add	a4,a4,a3
    800001f4:	01874703          	lbu	a4,24(a4)
    800001f8:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001fc:	4691                	li	a3,4
    800001fe:	06db8463          	beq	s7,a3,80000266 <consoleread+0x102>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    80000202:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000206:	4685                	li	a3,1
    80000208:	faf40613          	addi	a2,s0,-81
    8000020c:	85d2                	mv	a1,s4
    8000020e:	8556                	mv	a0,s5
    80000210:	00002097          	auipc	ra,0x2
    80000214:	246080e7          	jalr	582(ra) # 80002456 <either_copyout>
    80000218:	57fd                	li	a5,-1
    8000021a:	00f50763          	beq	a0,a5,80000228 <consoleread+0xc4>
      break;

    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    80000222:	47a9                	li	a5,10
    80000224:	f8fb90e3          	bne	s7,a5,800001a4 <consoleread+0x40>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000228:	00010517          	auipc	a0,0x10
    8000022c:	7e850513          	addi	a0,a0,2024 # 80010a10 <cons>
    80000230:	00001097          	auipc	ra,0x1
    80000234:	a56080e7          	jalr	-1450(ra) # 80000c86 <release>

  return target - n;
    80000238:	413b053b          	subw	a0,s6,s3
    8000023c:	a811                	j	80000250 <consoleread+0xec>
        release(&cons.lock);
    8000023e:	00010517          	auipc	a0,0x10
    80000242:	7d250513          	addi	a0,a0,2002 # 80010a10 <cons>
    80000246:	00001097          	auipc	ra,0x1
    8000024a:	a40080e7          	jalr	-1472(ra) # 80000c86 <release>
        return -1;
    8000024e:	557d                	li	a0,-1
}
    80000250:	60e6                	ld	ra,88(sp)
    80000252:	6446                	ld	s0,80(sp)
    80000254:	64a6                	ld	s1,72(sp)
    80000256:	6906                	ld	s2,64(sp)
    80000258:	79e2                	ld	s3,56(sp)
    8000025a:	7a42                	ld	s4,48(sp)
    8000025c:	7aa2                	ld	s5,40(sp)
    8000025e:	7b02                	ld	s6,32(sp)
    80000260:	6be2                	ld	s7,24(sp)
    80000262:	6125                	addi	sp,sp,96
    80000264:	8082                	ret
      if(n < target){
    80000266:	0009871b          	sext.w	a4,s3
    8000026a:	fb677fe3          	bgeu	a4,s6,80000228 <consoleread+0xc4>
        cons.r--;
    8000026e:	00011717          	auipc	a4,0x11
    80000272:	82f72d23          	sw	a5,-1990(a4) # 80010aa8 <cons+0x98>
    80000276:	bf4d                	j	80000228 <consoleread+0xc4>

0000000080000278 <consputc>:
{
    80000278:	1141                	addi	sp,sp,-16
    8000027a:	e406                	sd	ra,8(sp)
    8000027c:	e022                	sd	s0,0(sp)
    8000027e:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000280:	10000793          	li	a5,256
    80000284:	00f50a63          	beq	a0,a5,80000298 <consputc+0x20>
    uartputc_sync(c);
    80000288:	00000097          	auipc	ra,0x0
    8000028c:	560080e7          	jalr	1376(ra) # 800007e8 <uartputc_sync>
}
    80000290:	60a2                	ld	ra,8(sp)
    80000292:	6402                	ld	s0,0(sp)
    80000294:	0141                	addi	sp,sp,16
    80000296:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80000298:	4521                	li	a0,8
    8000029a:	00000097          	auipc	ra,0x0
    8000029e:	54e080e7          	jalr	1358(ra) # 800007e8 <uartputc_sync>
    800002a2:	02000513          	li	a0,32
    800002a6:	00000097          	auipc	ra,0x0
    800002aa:	542080e7          	jalr	1346(ra) # 800007e8 <uartputc_sync>
    800002ae:	4521                	li	a0,8
    800002b0:	00000097          	auipc	ra,0x0
    800002b4:	538080e7          	jalr	1336(ra) # 800007e8 <uartputc_sync>
    800002b8:	bfe1                	j	80000290 <consputc+0x18>

00000000800002ba <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002ba:	1101                	addi	sp,sp,-32
    800002bc:	ec06                	sd	ra,24(sp)
    800002be:	e822                	sd	s0,16(sp)
    800002c0:	e426                	sd	s1,8(sp)
    800002c2:	e04a                	sd	s2,0(sp)
    800002c4:	1000                	addi	s0,sp,32
    800002c6:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002c8:	00010517          	auipc	a0,0x10
    800002cc:	74850513          	addi	a0,a0,1864 # 80010a10 <cons>
    800002d0:	00001097          	auipc	ra,0x1
    800002d4:	902080e7          	jalr	-1790(ra) # 80000bd2 <acquire>

  switch(c){
    800002d8:	47d5                	li	a5,21
    800002da:	0af48663          	beq	s1,a5,80000386 <consoleintr+0xcc>
    800002de:	0297ca63          	blt	a5,s1,80000312 <consoleintr+0x58>
    800002e2:	47a1                	li	a5,8
    800002e4:	0ef48763          	beq	s1,a5,800003d2 <consoleintr+0x118>
    800002e8:	47c1                	li	a5,16
    800002ea:	10f49a63          	bne	s1,a5,800003fe <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002ee:	00002097          	auipc	ra,0x2
    800002f2:	214080e7          	jalr	532(ra) # 80002502 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002f6:	00010517          	auipc	a0,0x10
    800002fa:	71a50513          	addi	a0,a0,1818 # 80010a10 <cons>
    800002fe:	00001097          	auipc	ra,0x1
    80000302:	988080e7          	jalr	-1656(ra) # 80000c86 <release>
}
    80000306:	60e2                	ld	ra,24(sp)
    80000308:	6442                	ld	s0,16(sp)
    8000030a:	64a2                	ld	s1,8(sp)
    8000030c:	6902                	ld	s2,0(sp)
    8000030e:	6105                	addi	sp,sp,32
    80000310:	8082                	ret
  switch(c){
    80000312:	07f00793          	li	a5,127
    80000316:	0af48e63          	beq	s1,a5,800003d2 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031a:	00010717          	auipc	a4,0x10
    8000031e:	6f670713          	addi	a4,a4,1782 # 80010a10 <cons>
    80000322:	0a072783          	lw	a5,160(a4)
    80000326:	09872703          	lw	a4,152(a4)
    8000032a:	9f99                	subw	a5,a5,a4
    8000032c:	07f00713          	li	a4,127
    80000330:	fcf763e3          	bltu	a4,a5,800002f6 <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000334:	47b5                	li	a5,13
    80000336:	0cf48763          	beq	s1,a5,80000404 <consoleintr+0x14a>
      consputc(c);
    8000033a:	8526                	mv	a0,s1
    8000033c:	00000097          	auipc	ra,0x0
    80000340:	f3c080e7          	jalr	-196(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000344:	00010797          	auipc	a5,0x10
    80000348:	6cc78793          	addi	a5,a5,1740 # 80010a10 <cons>
    8000034c:	0a07a683          	lw	a3,160(a5)
    80000350:	0016871b          	addiw	a4,a3,1
    80000354:	0007061b          	sext.w	a2,a4
    80000358:	0ae7a023          	sw	a4,160(a5)
    8000035c:	07f6f693          	andi	a3,a3,127
    80000360:	97b6                	add	a5,a5,a3
    80000362:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    80000366:	47a9                	li	a5,10
    80000368:	0cf48563          	beq	s1,a5,80000432 <consoleintr+0x178>
    8000036c:	4791                	li	a5,4
    8000036e:	0cf48263          	beq	s1,a5,80000432 <consoleintr+0x178>
    80000372:	00010797          	auipc	a5,0x10
    80000376:	7367a783          	lw	a5,1846(a5) # 80010aa8 <cons+0x98>
    8000037a:	9f1d                	subw	a4,a4,a5
    8000037c:	08000793          	li	a5,128
    80000380:	f6f71be3          	bne	a4,a5,800002f6 <consoleintr+0x3c>
    80000384:	a07d                	j	80000432 <consoleintr+0x178>
    while(cons.e != cons.w &&
    80000386:	00010717          	auipc	a4,0x10
    8000038a:	68a70713          	addi	a4,a4,1674 # 80010a10 <cons>
    8000038e:	0a072783          	lw	a5,160(a4)
    80000392:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    80000396:	00010497          	auipc	s1,0x10
    8000039a:	67a48493          	addi	s1,s1,1658 # 80010a10 <cons>
    while(cons.e != cons.w &&
    8000039e:	4929                	li	s2,10
    800003a0:	f4f70be3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a4:	37fd                	addiw	a5,a5,-1
    800003a6:	07f7f713          	andi	a4,a5,127
    800003aa:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003ac:	01874703          	lbu	a4,24(a4)
    800003b0:	f52703e3          	beq	a4,s2,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003b4:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003b8:	10000513          	li	a0,256
    800003bc:	00000097          	auipc	ra,0x0
    800003c0:	ebc080e7          	jalr	-324(ra) # 80000278 <consputc>
    while(cons.e != cons.w &&
    800003c4:	0a04a783          	lw	a5,160(s1)
    800003c8:	09c4a703          	lw	a4,156(s1)
    800003cc:	fcf71ce3          	bne	a4,a5,800003a4 <consoleintr+0xea>
    800003d0:	b71d                	j	800002f6 <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d2:	00010717          	auipc	a4,0x10
    800003d6:	63e70713          	addi	a4,a4,1598 # 80010a10 <cons>
    800003da:	0a072783          	lw	a5,160(a4)
    800003de:	09c72703          	lw	a4,156(a4)
    800003e2:	f0f70ae3          	beq	a4,a5,800002f6 <consoleintr+0x3c>
      cons.e--;
    800003e6:	37fd                	addiw	a5,a5,-1
    800003e8:	00010717          	auipc	a4,0x10
    800003ec:	6cf72423          	sw	a5,1736(a4) # 80010ab0 <cons+0xa0>
      consputc(BACKSPACE);
    800003f0:	10000513          	li	a0,256
    800003f4:	00000097          	auipc	ra,0x0
    800003f8:	e84080e7          	jalr	-380(ra) # 80000278 <consputc>
    800003fc:	bded                	j	800002f6 <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003fe:	ee048ce3          	beqz	s1,800002f6 <consoleintr+0x3c>
    80000402:	bf21                	j	8000031a <consoleintr+0x60>
      consputc(c);
    80000404:	4529                	li	a0,10
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	e72080e7          	jalr	-398(ra) # 80000278 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    8000040e:	00010797          	auipc	a5,0x10
    80000412:	60278793          	addi	a5,a5,1538 # 80010a10 <cons>
    80000416:	0a07a703          	lw	a4,160(a5)
    8000041a:	0017069b          	addiw	a3,a4,1
    8000041e:	0006861b          	sext.w	a2,a3
    80000422:	0ad7a023          	sw	a3,160(a5)
    80000426:	07f77713          	andi	a4,a4,127
    8000042a:	97ba                	add	a5,a5,a4
    8000042c:	4729                	li	a4,10
    8000042e:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000432:	00010797          	auipc	a5,0x10
    80000436:	66c7ad23          	sw	a2,1658(a5) # 80010aac <cons+0x9c>
        wakeup(&cons.r);
    8000043a:	00010517          	auipc	a0,0x10
    8000043e:	66e50513          	addi	a0,a0,1646 # 80010aa8 <cons+0x98>
    80000442:	00002097          	auipc	ra,0x2
    80000446:	c70080e7          	jalr	-912(ra) # 800020b2 <wakeup>
    8000044a:	b575                	j	800002f6 <consoleintr+0x3c>

000000008000044c <consoleinit>:

void
consoleinit(void)
{
    8000044c:	1141                	addi	sp,sp,-16
    8000044e:	e406                	sd	ra,8(sp)
    80000450:	e022                	sd	s0,0(sp)
    80000452:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000454:	00008597          	auipc	a1,0x8
    80000458:	bbc58593          	addi	a1,a1,-1092 # 80008010 <etext+0x10>
    8000045c:	00010517          	auipc	a0,0x10
    80000460:	5b450513          	addi	a0,a0,1460 # 80010a10 <cons>
    80000464:	00000097          	auipc	ra,0x0
    80000468:	6de080e7          	jalr	1758(ra) # 80000b42 <initlock>

  uartinit();
    8000046c:	00000097          	auipc	ra,0x0
    80000470:	32c080e7          	jalr	812(ra) # 80000798 <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000474:	00020797          	auipc	a5,0x20
    80000478:	73478793          	addi	a5,a5,1844 # 80020ba8 <devsw>
    8000047c:	00000717          	auipc	a4,0x0
    80000480:	ce870713          	addi	a4,a4,-792 # 80000164 <consoleread>
    80000484:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80000486:	00000717          	auipc	a4,0x0
    8000048a:	c7a70713          	addi	a4,a4,-902 # 80000100 <consolewrite>
    8000048e:	ef98                	sd	a4,24(a5)
}
    80000490:	60a2                	ld	ra,8(sp)
    80000492:	6402                	ld	s0,0(sp)
    80000494:	0141                	addi	sp,sp,16
    80000496:	8082                	ret

0000000080000498 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80000498:	7179                	addi	sp,sp,-48
    8000049a:	f406                	sd	ra,40(sp)
    8000049c:	f022                	sd	s0,32(sp)
    8000049e:	ec26                	sd	s1,24(sp)
    800004a0:	e84a                	sd	s2,16(sp)
    800004a2:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a4:	c219                	beqz	a2,800004aa <printint+0x12>
    800004a6:	08054763          	bltz	a0,80000534 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004aa:	2501                	sext.w	a0,a0
    800004ac:	4881                	li	a7,0
    800004ae:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b2:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b4:	2581                	sext.w	a1,a1
    800004b6:	00008617          	auipc	a2,0x8
    800004ba:	b8a60613          	addi	a2,a2,-1142 # 80008040 <digits>
    800004be:	883a                	mv	a6,a4
    800004c0:	2705                	addiw	a4,a4,1
    800004c2:	02b577bb          	remuw	a5,a0,a1
    800004c6:	1782                	slli	a5,a5,0x20
    800004c8:	9381                	srli	a5,a5,0x20
    800004ca:	97b2                	add	a5,a5,a2
    800004cc:	0007c783          	lbu	a5,0(a5)
    800004d0:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d4:	0005079b          	sext.w	a5,a0
    800004d8:	02b5553b          	divuw	a0,a0,a1
    800004dc:	0685                	addi	a3,a3,1
    800004de:	feb7f0e3          	bgeu	a5,a1,800004be <printint+0x26>

  if(sign)
    800004e2:	00088c63          	beqz	a7,800004fa <printint+0x62>
    buf[i++] = '-';
    800004e6:	fe070793          	addi	a5,a4,-32
    800004ea:	00878733          	add	a4,a5,s0
    800004ee:	02d00793          	li	a5,45
    800004f2:	fef70823          	sb	a5,-16(a4)
    800004f6:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fa:	02e05763          	blez	a4,80000528 <printint+0x90>
    800004fe:	fd040793          	addi	a5,s0,-48
    80000502:	00e784b3          	add	s1,a5,a4
    80000506:	fff78913          	addi	s2,a5,-1
    8000050a:	993a                	add	s2,s2,a4
    8000050c:	377d                	addiw	a4,a4,-1
    8000050e:	1702                	slli	a4,a4,0x20
    80000510:	9301                	srli	a4,a4,0x20
    80000512:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    80000516:	fff4c503          	lbu	a0,-1(s1)
    8000051a:	00000097          	auipc	ra,0x0
    8000051e:	d5e080e7          	jalr	-674(ra) # 80000278 <consputc>
  while(--i >= 0)
    80000522:	14fd                	addi	s1,s1,-1
    80000524:	ff2499e3          	bne	s1,s2,80000516 <printint+0x7e>
}
    80000528:	70a2                	ld	ra,40(sp)
    8000052a:	7402                	ld	s0,32(sp)
    8000052c:	64e2                	ld	s1,24(sp)
    8000052e:	6942                	ld	s2,16(sp)
    80000530:	6145                	addi	sp,sp,48
    80000532:	8082                	ret
    x = -xx;
    80000534:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    80000538:	4885                	li	a7,1
    x = -xx;
    8000053a:	bf95                	j	800004ae <printint+0x16>

000000008000053c <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    8000053c:	1101                	addi	sp,sp,-32
    8000053e:	ec06                	sd	ra,24(sp)
    80000540:	e822                	sd	s0,16(sp)
    80000542:	e426                	sd	s1,8(sp)
    80000544:	1000                	addi	s0,sp,32
    80000546:	84aa                	mv	s1,a0
  pr.locking = 0;
    80000548:	00010797          	auipc	a5,0x10
    8000054c:	5807a423          	sw	zero,1416(a5) # 80010ad0 <pr+0x18>
  printf("panic: ");
    80000550:	00008517          	auipc	a0,0x8
    80000554:	ac850513          	addi	a0,a0,-1336 # 80008018 <etext+0x18>
    80000558:	00000097          	auipc	ra,0x0
    8000055c:	02e080e7          	jalr	46(ra) # 80000586 <printf>
  printf(s);
    80000560:	8526                	mv	a0,s1
    80000562:	00000097          	auipc	ra,0x0
    80000566:	024080e7          	jalr	36(ra) # 80000586 <printf>
  printf("\n");
    8000056a:	00008517          	auipc	a0,0x8
    8000056e:	b5e50513          	addi	a0,a0,-1186 # 800080c8 <digits+0x88>
    80000572:	00000097          	auipc	ra,0x0
    80000576:	014080e7          	jalr	20(ra) # 80000586 <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057a:	4785                	li	a5,1
    8000057c:	00008717          	auipc	a4,0x8
    80000580:	30f72a23          	sw	a5,788(a4) # 80008890 <panicked>
  for(;;)
    80000584:	a001                	j	80000584 <panic+0x48>

0000000080000586 <printf>:
{
    80000586:	7131                	addi	sp,sp,-192
    80000588:	fc86                	sd	ra,120(sp)
    8000058a:	f8a2                	sd	s0,112(sp)
    8000058c:	f4a6                	sd	s1,104(sp)
    8000058e:	f0ca                	sd	s2,96(sp)
    80000590:	ecce                	sd	s3,88(sp)
    80000592:	e8d2                	sd	s4,80(sp)
    80000594:	e4d6                	sd	s5,72(sp)
    80000596:	e0da                	sd	s6,64(sp)
    80000598:	fc5e                	sd	s7,56(sp)
    8000059a:	f862                	sd	s8,48(sp)
    8000059c:	f466                	sd	s9,40(sp)
    8000059e:	f06a                	sd	s10,32(sp)
    800005a0:	ec6e                	sd	s11,24(sp)
    800005a2:	0100                	addi	s0,sp,128
    800005a4:	8a2a                	mv	s4,a0
    800005a6:	e40c                	sd	a1,8(s0)
    800005a8:	e810                	sd	a2,16(s0)
    800005aa:	ec14                	sd	a3,24(s0)
    800005ac:	f018                	sd	a4,32(s0)
    800005ae:	f41c                	sd	a5,40(s0)
    800005b0:	03043823          	sd	a6,48(s0)
    800005b4:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005b8:	00010d97          	auipc	s11,0x10
    800005bc:	518dad83          	lw	s11,1304(s11) # 80010ad0 <pr+0x18>
  if(locking)
    800005c0:	020d9b63          	bnez	s11,800005f6 <printf+0x70>
  if (fmt == 0)
    800005c4:	040a0263          	beqz	s4,80000608 <printf+0x82>
  va_start(ap, fmt);
    800005c8:	00840793          	addi	a5,s0,8
    800005cc:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d0:	000a4503          	lbu	a0,0(s4)
    800005d4:	14050f63          	beqz	a0,80000732 <printf+0x1ac>
    800005d8:	4981                	li	s3,0
    if(c != '%'){
    800005da:	02500a93          	li	s5,37
    switch(c){
    800005de:	07000b93          	li	s7,112
  consputc('x');
    800005e2:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e4:	00008b17          	auipc	s6,0x8
    800005e8:	a5cb0b13          	addi	s6,s6,-1444 # 80008040 <digits>
    switch(c){
    800005ec:	07300c93          	li	s9,115
    800005f0:	06400c13          	li	s8,100
    800005f4:	a82d                	j	8000062e <printf+0xa8>
    acquire(&pr.lock);
    800005f6:	00010517          	auipc	a0,0x10
    800005fa:	4c250513          	addi	a0,a0,1218 # 80010ab8 <pr>
    800005fe:	00000097          	auipc	ra,0x0
    80000602:	5d4080e7          	jalr	1492(ra) # 80000bd2 <acquire>
    80000606:	bf7d                	j	800005c4 <printf+0x3e>
    panic("null fmt");
    80000608:	00008517          	auipc	a0,0x8
    8000060c:	a2050513          	addi	a0,a0,-1504 # 80008028 <etext+0x28>
    80000610:	00000097          	auipc	ra,0x0
    80000614:	f2c080e7          	jalr	-212(ra) # 8000053c <panic>
      consputc(c);
    80000618:	00000097          	auipc	ra,0x0
    8000061c:	c60080e7          	jalr	-928(ra) # 80000278 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000620:	2985                	addiw	s3,s3,1
    80000622:	013a07b3          	add	a5,s4,s3
    80000626:	0007c503          	lbu	a0,0(a5)
    8000062a:	10050463          	beqz	a0,80000732 <printf+0x1ac>
    if(c != '%'){
    8000062e:	ff5515e3          	bne	a0,s5,80000618 <printf+0x92>
    c = fmt[++i] & 0xff;
    80000632:	2985                	addiw	s3,s3,1
    80000634:	013a07b3          	add	a5,s4,s3
    80000638:	0007c783          	lbu	a5,0(a5)
    8000063c:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000640:	cbed                	beqz	a5,80000732 <printf+0x1ac>
    switch(c){
    80000642:	05778a63          	beq	a5,s7,80000696 <printf+0x110>
    80000646:	02fbf663          	bgeu	s7,a5,80000672 <printf+0xec>
    8000064a:	09978863          	beq	a5,s9,800006da <printf+0x154>
    8000064e:	07800713          	li	a4,120
    80000652:	0ce79563          	bne	a5,a4,8000071c <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    80000656:	f8843783          	ld	a5,-120(s0)
    8000065a:	00878713          	addi	a4,a5,8
    8000065e:	f8e43423          	sd	a4,-120(s0)
    80000662:	4605                	li	a2,1
    80000664:	85ea                	mv	a1,s10
    80000666:	4388                	lw	a0,0(a5)
    80000668:	00000097          	auipc	ra,0x0
    8000066c:	e30080e7          	jalr	-464(ra) # 80000498 <printint>
      break;
    80000670:	bf45                	j	80000620 <printf+0x9a>
    switch(c){
    80000672:	09578f63          	beq	a5,s5,80000710 <printf+0x18a>
    80000676:	0b879363          	bne	a5,s8,8000071c <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067a:	f8843783          	ld	a5,-120(s0)
    8000067e:	00878713          	addi	a4,a5,8
    80000682:	f8e43423          	sd	a4,-120(s0)
    80000686:	4605                	li	a2,1
    80000688:	45a9                	li	a1,10
    8000068a:	4388                	lw	a0,0(a5)
    8000068c:	00000097          	auipc	ra,0x0
    80000690:	e0c080e7          	jalr	-500(ra) # 80000498 <printint>
      break;
    80000694:	b771                	j	80000620 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    80000696:	f8843783          	ld	a5,-120(s0)
    8000069a:	00878713          	addi	a4,a5,8
    8000069e:	f8e43423          	sd	a4,-120(s0)
    800006a2:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006a6:	03000513          	li	a0,48
    800006aa:	00000097          	auipc	ra,0x0
    800006ae:	bce080e7          	jalr	-1074(ra) # 80000278 <consputc>
  consputc('x');
    800006b2:	07800513          	li	a0,120
    800006b6:	00000097          	auipc	ra,0x0
    800006ba:	bc2080e7          	jalr	-1086(ra) # 80000278 <consputc>
    800006be:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c0:	03c95793          	srli	a5,s2,0x3c
    800006c4:	97da                	add	a5,a5,s6
    800006c6:	0007c503          	lbu	a0,0(a5)
    800006ca:	00000097          	auipc	ra,0x0
    800006ce:	bae080e7          	jalr	-1106(ra) # 80000278 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d2:	0912                	slli	s2,s2,0x4
    800006d4:	34fd                	addiw	s1,s1,-1
    800006d6:	f4ed                	bnez	s1,800006c0 <printf+0x13a>
    800006d8:	b7a1                	j	80000620 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006da:	f8843783          	ld	a5,-120(s0)
    800006de:	00878713          	addi	a4,a5,8
    800006e2:	f8e43423          	sd	a4,-120(s0)
    800006e6:	6384                	ld	s1,0(a5)
    800006e8:	cc89                	beqz	s1,80000702 <printf+0x17c>
      for(; *s; s++)
    800006ea:	0004c503          	lbu	a0,0(s1)
    800006ee:	d90d                	beqz	a0,80000620 <printf+0x9a>
        consputc(*s);
    800006f0:	00000097          	auipc	ra,0x0
    800006f4:	b88080e7          	jalr	-1144(ra) # 80000278 <consputc>
      for(; *s; s++)
    800006f8:	0485                	addi	s1,s1,1
    800006fa:	0004c503          	lbu	a0,0(s1)
    800006fe:	f96d                	bnez	a0,800006f0 <printf+0x16a>
    80000700:	b705                	j	80000620 <printf+0x9a>
        s = "(null)";
    80000702:	00008497          	auipc	s1,0x8
    80000706:	91e48493          	addi	s1,s1,-1762 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070a:	02800513          	li	a0,40
    8000070e:	b7cd                	j	800006f0 <printf+0x16a>
      consputc('%');
    80000710:	8556                	mv	a0,s5
    80000712:	00000097          	auipc	ra,0x0
    80000716:	b66080e7          	jalr	-1178(ra) # 80000278 <consputc>
      break;
    8000071a:	b719                	j	80000620 <printf+0x9a>
      consputc('%');
    8000071c:	8556                	mv	a0,s5
    8000071e:	00000097          	auipc	ra,0x0
    80000722:	b5a080e7          	jalr	-1190(ra) # 80000278 <consputc>
      consputc(c);
    80000726:	8526                	mv	a0,s1
    80000728:	00000097          	auipc	ra,0x0
    8000072c:	b50080e7          	jalr	-1200(ra) # 80000278 <consputc>
      break;
    80000730:	bdc5                	j	80000620 <printf+0x9a>
  if(locking)
    80000732:	020d9163          	bnez	s11,80000754 <printf+0x1ce>
}
    80000736:	70e6                	ld	ra,120(sp)
    80000738:	7446                	ld	s0,112(sp)
    8000073a:	74a6                	ld	s1,104(sp)
    8000073c:	7906                	ld	s2,96(sp)
    8000073e:	69e6                	ld	s3,88(sp)
    80000740:	6a46                	ld	s4,80(sp)
    80000742:	6aa6                	ld	s5,72(sp)
    80000744:	6b06                	ld	s6,64(sp)
    80000746:	7be2                	ld	s7,56(sp)
    80000748:	7c42                	ld	s8,48(sp)
    8000074a:	7ca2                	ld	s9,40(sp)
    8000074c:	7d02                	ld	s10,32(sp)
    8000074e:	6de2                	ld	s11,24(sp)
    80000750:	6129                	addi	sp,sp,192
    80000752:	8082                	ret
    release(&pr.lock);
    80000754:	00010517          	auipc	a0,0x10
    80000758:	36450513          	addi	a0,a0,868 # 80010ab8 <pr>
    8000075c:	00000097          	auipc	ra,0x0
    80000760:	52a080e7          	jalr	1322(ra) # 80000c86 <release>
}
    80000764:	bfc9                	j	80000736 <printf+0x1b0>

0000000080000766 <printfinit>:
    ;
}

void
printfinit(void)
{
    80000766:	1101                	addi	sp,sp,-32
    80000768:	ec06                	sd	ra,24(sp)
    8000076a:	e822                	sd	s0,16(sp)
    8000076c:	e426                	sd	s1,8(sp)
    8000076e:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000770:	00010497          	auipc	s1,0x10
    80000774:	34848493          	addi	s1,s1,840 # 80010ab8 <pr>
    80000778:	00008597          	auipc	a1,0x8
    8000077c:	8c058593          	addi	a1,a1,-1856 # 80008038 <etext+0x38>
    80000780:	8526                	mv	a0,s1
    80000782:	00000097          	auipc	ra,0x0
    80000786:	3c0080e7          	jalr	960(ra) # 80000b42 <initlock>
  pr.locking = 1;
    8000078a:	4785                	li	a5,1
    8000078c:	cc9c                	sw	a5,24(s1)
}
    8000078e:	60e2                	ld	ra,24(sp)
    80000790:	6442                	ld	s0,16(sp)
    80000792:	64a2                	ld	s1,8(sp)
    80000794:	6105                	addi	sp,sp,32
    80000796:	8082                	ret

0000000080000798 <uartinit>:

void uartstart();

void
uartinit(void)
{
    80000798:	1141                	addi	sp,sp,-16
    8000079a:	e406                	sd	ra,8(sp)
    8000079c:	e022                	sd	s0,0(sp)
    8000079e:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a0:	100007b7          	lui	a5,0x10000
    800007a4:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007a8:	f8000713          	li	a4,-128
    800007ac:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b0:	470d                	li	a4,3
    800007b2:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007b6:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007ba:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007be:	469d                	li	a3,7
    800007c0:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c4:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007c8:	00008597          	auipc	a1,0x8
    800007cc:	89058593          	addi	a1,a1,-1904 # 80008058 <digits+0x18>
    800007d0:	00010517          	auipc	a0,0x10
    800007d4:	30850513          	addi	a0,a0,776 # 80010ad8 <uart_tx_lock>
    800007d8:	00000097          	auipc	ra,0x0
    800007dc:	36a080e7          	jalr	874(ra) # 80000b42 <initlock>
}
    800007e0:	60a2                	ld	ra,8(sp)
    800007e2:	6402                	ld	s0,0(sp)
    800007e4:	0141                	addi	sp,sp,16
    800007e6:	8082                	ret

00000000800007e8 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007e8:	1101                	addi	sp,sp,-32
    800007ea:	ec06                	sd	ra,24(sp)
    800007ec:	e822                	sd	s0,16(sp)
    800007ee:	e426                	sd	s1,8(sp)
    800007f0:	1000                	addi	s0,sp,32
    800007f2:	84aa                	mv	s1,a0
  push_off();
    800007f4:	00000097          	auipc	ra,0x0
    800007f8:	392080e7          	jalr	914(ra) # 80000b86 <push_off>

  if(panicked){
    800007fc:	00008797          	auipc	a5,0x8
    80000800:	0947a783          	lw	a5,148(a5) # 80008890 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000804:	10000737          	lui	a4,0x10000
  if(panicked){
    80000808:	c391                	beqz	a5,8000080c <uartputc_sync+0x24>
    for(;;)
    8000080a:	a001                	j	8000080a <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000080c:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000810:	0207f793          	andi	a5,a5,32
    80000814:	dfe5                	beqz	a5,8000080c <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    80000816:	0ff4f513          	zext.b	a0,s1
    8000081a:	100007b7          	lui	a5,0x10000
    8000081e:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000822:	00000097          	auipc	ra,0x0
    80000826:	404080e7          	jalr	1028(ra) # 80000c26 <pop_off>
}
    8000082a:	60e2                	ld	ra,24(sp)
    8000082c:	6442                	ld	s0,16(sp)
    8000082e:	64a2                	ld	s1,8(sp)
    80000830:	6105                	addi	sp,sp,32
    80000832:	8082                	ret

0000000080000834 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000834:	00008797          	auipc	a5,0x8
    80000838:	0647b783          	ld	a5,100(a5) # 80008898 <uart_tx_r>
    8000083c:	00008717          	auipc	a4,0x8
    80000840:	06473703          	ld	a4,100(a4) # 800088a0 <uart_tx_w>
    80000844:	06f70a63          	beq	a4,a5,800008b8 <uartstart+0x84>
{
    80000848:	7139                	addi	sp,sp,-64
    8000084a:	fc06                	sd	ra,56(sp)
    8000084c:	f822                	sd	s0,48(sp)
    8000084e:	f426                	sd	s1,40(sp)
    80000850:	f04a                	sd	s2,32(sp)
    80000852:	ec4e                	sd	s3,24(sp)
    80000854:	e852                	sd	s4,16(sp)
    80000856:	e456                	sd	s5,8(sp)
    80000858:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085a:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    8000085e:	00010a17          	auipc	s4,0x10
    80000862:	27aa0a13          	addi	s4,s4,634 # 80010ad8 <uart_tx_lock>
    uart_tx_r += 1;
    80000866:	00008497          	auipc	s1,0x8
    8000086a:	03248493          	addi	s1,s1,50 # 80008898 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    8000086e:	00008997          	auipc	s3,0x8
    80000872:	03298993          	addi	s3,s3,50 # 800088a0 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    80000876:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087a:	02077713          	andi	a4,a4,32
    8000087e:	c705                	beqz	a4,800008a6 <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000880:	01f7f713          	andi	a4,a5,31
    80000884:	9752                	add	a4,a4,s4
    80000886:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088a:	0785                	addi	a5,a5,1
    8000088c:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    8000088e:	8526                	mv	a0,s1
    80000890:	00002097          	auipc	ra,0x2
    80000894:	822080e7          	jalr	-2014(ra) # 800020b2 <wakeup>
    
    WriteReg(THR, c);
    80000898:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    8000089c:	609c                	ld	a5,0(s1)
    8000089e:	0009b703          	ld	a4,0(s3)
    800008a2:	fcf71ae3          	bne	a4,a5,80000876 <uartstart+0x42>
  }
}
    800008a6:	70e2                	ld	ra,56(sp)
    800008a8:	7442                	ld	s0,48(sp)
    800008aa:	74a2                	ld	s1,40(sp)
    800008ac:	7902                	ld	s2,32(sp)
    800008ae:	69e2                	ld	s3,24(sp)
    800008b0:	6a42                	ld	s4,16(sp)
    800008b2:	6aa2                	ld	s5,8(sp)
    800008b4:	6121                	addi	sp,sp,64
    800008b6:	8082                	ret
    800008b8:	8082                	ret

00000000800008ba <uartputc>:
{
    800008ba:	7179                	addi	sp,sp,-48
    800008bc:	f406                	sd	ra,40(sp)
    800008be:	f022                	sd	s0,32(sp)
    800008c0:	ec26                	sd	s1,24(sp)
    800008c2:	e84a                	sd	s2,16(sp)
    800008c4:	e44e                	sd	s3,8(sp)
    800008c6:	e052                	sd	s4,0(sp)
    800008c8:	1800                	addi	s0,sp,48
    800008ca:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008cc:	00010517          	auipc	a0,0x10
    800008d0:	20c50513          	addi	a0,a0,524 # 80010ad8 <uart_tx_lock>
    800008d4:	00000097          	auipc	ra,0x0
    800008d8:	2fe080e7          	jalr	766(ra) # 80000bd2 <acquire>
  if(panicked){
    800008dc:	00008797          	auipc	a5,0x8
    800008e0:	fb47a783          	lw	a5,-76(a5) # 80008890 <panicked>
    800008e4:	e7c9                	bnez	a5,8000096e <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008e6:	00008717          	auipc	a4,0x8
    800008ea:	fba73703          	ld	a4,-70(a4) # 800088a0 <uart_tx_w>
    800008ee:	00008797          	auipc	a5,0x8
    800008f2:	faa7b783          	ld	a5,-86(a5) # 80008898 <uart_tx_r>
    800008f6:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fa:	00010997          	auipc	s3,0x10
    800008fe:	1de98993          	addi	s3,s3,478 # 80010ad8 <uart_tx_lock>
    80000902:	00008497          	auipc	s1,0x8
    80000906:	f9648493          	addi	s1,s1,-106 # 80008898 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090a:	00008917          	auipc	s2,0x8
    8000090e:	f9690913          	addi	s2,s2,-106 # 800088a0 <uart_tx_w>
    80000912:	00e79f63          	bne	a5,a4,80000930 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000916:	85ce                	mv	a1,s3
    80000918:	8526                	mv	a0,s1
    8000091a:	00001097          	auipc	ra,0x1
    8000091e:	734080e7          	jalr	1844(ra) # 8000204e <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000922:	00093703          	ld	a4,0(s2)
    80000926:	609c                	ld	a5,0(s1)
    80000928:	02078793          	addi	a5,a5,32
    8000092c:	fee785e3          	beq	a5,a4,80000916 <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000930:	00010497          	auipc	s1,0x10
    80000934:	1a848493          	addi	s1,s1,424 # 80010ad8 <uart_tx_lock>
    80000938:	01f77793          	andi	a5,a4,31
    8000093c:	97a6                	add	a5,a5,s1
    8000093e:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000942:	0705                	addi	a4,a4,1
    80000944:	00008797          	auipc	a5,0x8
    80000948:	f4e7be23          	sd	a4,-164(a5) # 800088a0 <uart_tx_w>
  uartstart();
    8000094c:	00000097          	auipc	ra,0x0
    80000950:	ee8080e7          	jalr	-280(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    80000954:	8526                	mv	a0,s1
    80000956:	00000097          	auipc	ra,0x0
    8000095a:	330080e7          	jalr	816(ra) # 80000c86 <release>
}
    8000095e:	70a2                	ld	ra,40(sp)
    80000960:	7402                	ld	s0,32(sp)
    80000962:	64e2                	ld	s1,24(sp)
    80000964:	6942                	ld	s2,16(sp)
    80000966:	69a2                	ld	s3,8(sp)
    80000968:	6a02                	ld	s4,0(sp)
    8000096a:	6145                	addi	sp,sp,48
    8000096c:	8082                	ret
    for(;;)
    8000096e:	a001                	j	8000096e <uartputc+0xb4>

0000000080000970 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000970:	1141                	addi	sp,sp,-16
    80000972:	e422                	sd	s0,8(sp)
    80000974:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    80000976:	100007b7          	lui	a5,0x10000
    8000097a:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    8000097e:	8b85                	andi	a5,a5,1
    80000980:	cb81                	beqz	a5,80000990 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000982:	100007b7          	lui	a5,0x10000
    80000986:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098a:	6422                	ld	s0,8(sp)
    8000098c:	0141                	addi	sp,sp,16
    8000098e:	8082                	ret
    return -1;
    80000990:	557d                	li	a0,-1
    80000992:	bfe5                	j	8000098a <uartgetc+0x1a>

0000000080000994 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000994:	1101                	addi	sp,sp,-32
    80000996:	ec06                	sd	ra,24(sp)
    80000998:	e822                	sd	s0,16(sp)
    8000099a:	e426                	sd	s1,8(sp)
    8000099c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000099e:	54fd                	li	s1,-1
    800009a0:	a029                	j	800009aa <uartintr+0x16>
      break;
    consoleintr(c);
    800009a2:	00000097          	auipc	ra,0x0
    800009a6:	918080e7          	jalr	-1768(ra) # 800002ba <consoleintr>
    int c = uartgetc();
    800009aa:	00000097          	auipc	ra,0x0
    800009ae:	fc6080e7          	jalr	-58(ra) # 80000970 <uartgetc>
    if(c == -1)
    800009b2:	fe9518e3          	bne	a0,s1,800009a2 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009b6:	00010497          	auipc	s1,0x10
    800009ba:	12248493          	addi	s1,s1,290 # 80010ad8 <uart_tx_lock>
    800009be:	8526                	mv	a0,s1
    800009c0:	00000097          	auipc	ra,0x0
    800009c4:	212080e7          	jalr	530(ra) # 80000bd2 <acquire>
  uartstart();
    800009c8:	00000097          	auipc	ra,0x0
    800009cc:	e6c080e7          	jalr	-404(ra) # 80000834 <uartstart>
  release(&uart_tx_lock);
    800009d0:	8526                	mv	a0,s1
    800009d2:	00000097          	auipc	ra,0x0
    800009d6:	2b4080e7          	jalr	692(ra) # 80000c86 <release>
}
    800009da:	60e2                	ld	ra,24(sp)
    800009dc:	6442                	ld	s0,16(sp)
    800009de:	64a2                	ld	s1,8(sp)
    800009e0:	6105                	addi	sp,sp,32
    800009e2:	8082                	ret

00000000800009e4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e4:	1101                	addi	sp,sp,-32
    800009e6:	ec06                	sd	ra,24(sp)
    800009e8:	e822                	sd	s0,16(sp)
    800009ea:	e426                	sd	s1,8(sp)
    800009ec:	e04a                	sd	s2,0(sp)
    800009ee:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f0:	03451793          	slli	a5,a0,0x34
    800009f4:	ebb9                	bnez	a5,80000a4a <kfree+0x66>
    800009f6:	84aa                	mv	s1,a0
    800009f8:	00021797          	auipc	a5,0x21
    800009fc:	34878793          	addi	a5,a5,840 # 80021d40 <end>
    80000a00:	04f56563          	bltu	a0,a5,80000a4a <kfree+0x66>
    80000a04:	47c5                	li	a5,17
    80000a06:	07ee                	slli	a5,a5,0x1b
    80000a08:	04f57163          	bgeu	a0,a5,80000a4a <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a0c:	6605                	lui	a2,0x1
    80000a0e:	4585                	li	a1,1
    80000a10:	00000097          	auipc	ra,0x0
    80000a14:	2be080e7          	jalr	702(ra) # 80000cce <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a18:	00010917          	auipc	s2,0x10
    80000a1c:	0f890913          	addi	s2,s2,248 # 80010b10 <kmem>
    80000a20:	854a                	mv	a0,s2
    80000a22:	00000097          	auipc	ra,0x0
    80000a26:	1b0080e7          	jalr	432(ra) # 80000bd2 <acquire>
  r->next = kmem.freelist;
    80000a2a:	01893783          	ld	a5,24(s2)
    80000a2e:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a30:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a34:	854a                	mv	a0,s2
    80000a36:	00000097          	auipc	ra,0x0
    80000a3a:	250080e7          	jalr	592(ra) # 80000c86 <release>
}
    80000a3e:	60e2                	ld	ra,24(sp)
    80000a40:	6442                	ld	s0,16(sp)
    80000a42:	64a2                	ld	s1,8(sp)
    80000a44:	6902                	ld	s2,0(sp)
    80000a46:	6105                	addi	sp,sp,32
    80000a48:	8082                	ret
    panic("kfree");
    80000a4a:	00007517          	auipc	a0,0x7
    80000a4e:	61650513          	addi	a0,a0,1558 # 80008060 <digits+0x20>
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	aea080e7          	jalr	-1302(ra) # 8000053c <panic>

0000000080000a5a <freerange>:
{
    80000a5a:	7179                	addi	sp,sp,-48
    80000a5c:	f406                	sd	ra,40(sp)
    80000a5e:	f022                	sd	s0,32(sp)
    80000a60:	ec26                	sd	s1,24(sp)
    80000a62:	e84a                	sd	s2,16(sp)
    80000a64:	e44e                	sd	s3,8(sp)
    80000a66:	e052                	sd	s4,0(sp)
    80000a68:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6a:	6785                	lui	a5,0x1
    80000a6c:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a70:	00e504b3          	add	s1,a0,a4
    80000a74:	777d                	lui	a4,0xfffff
    80000a76:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a78:	94be                	add	s1,s1,a5
    80000a7a:	0095ee63          	bltu	a1,s1,80000a96 <freerange+0x3c>
    80000a7e:	892e                	mv	s2,a1
    kfree(p);
    80000a80:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a82:	6985                	lui	s3,0x1
    kfree(p);
    80000a84:	01448533          	add	a0,s1,s4
    80000a88:	00000097          	auipc	ra,0x0
    80000a8c:	f5c080e7          	jalr	-164(ra) # 800009e4 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a90:	94ce                	add	s1,s1,s3
    80000a92:	fe9979e3          	bgeu	s2,s1,80000a84 <freerange+0x2a>
}
    80000a96:	70a2                	ld	ra,40(sp)
    80000a98:	7402                	ld	s0,32(sp)
    80000a9a:	64e2                	ld	s1,24(sp)
    80000a9c:	6942                	ld	s2,16(sp)
    80000a9e:	69a2                	ld	s3,8(sp)
    80000aa0:	6a02                	ld	s4,0(sp)
    80000aa2:	6145                	addi	sp,sp,48
    80000aa4:	8082                	ret

0000000080000aa6 <kinit>:
{
    80000aa6:	1141                	addi	sp,sp,-16
    80000aa8:	e406                	sd	ra,8(sp)
    80000aaa:	e022                	sd	s0,0(sp)
    80000aac:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000aae:	00007597          	auipc	a1,0x7
    80000ab2:	5ba58593          	addi	a1,a1,1466 # 80008068 <digits+0x28>
    80000ab6:	00010517          	auipc	a0,0x10
    80000aba:	05a50513          	addi	a0,a0,90 # 80010b10 <kmem>
    80000abe:	00000097          	auipc	ra,0x0
    80000ac2:	084080e7          	jalr	132(ra) # 80000b42 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000ac6:	45c5                	li	a1,17
    80000ac8:	05ee                	slli	a1,a1,0x1b
    80000aca:	00021517          	auipc	a0,0x21
    80000ace:	27650513          	addi	a0,a0,630 # 80021d40 <end>
    80000ad2:	00000097          	auipc	ra,0x0
    80000ad6:	f88080e7          	jalr	-120(ra) # 80000a5a <freerange>
}
    80000ada:	60a2                	ld	ra,8(sp)
    80000adc:	6402                	ld	s0,0(sp)
    80000ade:	0141                	addi	sp,sp,16
    80000ae0:	8082                	ret

0000000080000ae2 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae2:	1101                	addi	sp,sp,-32
    80000ae4:	ec06                	sd	ra,24(sp)
    80000ae6:	e822                	sd	s0,16(sp)
    80000ae8:	e426                	sd	s1,8(sp)
    80000aea:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000aec:	00010497          	auipc	s1,0x10
    80000af0:	02448493          	addi	s1,s1,36 # 80010b10 <kmem>
    80000af4:	8526                	mv	a0,s1
    80000af6:	00000097          	auipc	ra,0x0
    80000afa:	0dc080e7          	jalr	220(ra) # 80000bd2 <acquire>
  r = kmem.freelist;
    80000afe:	6c84                	ld	s1,24(s1)
  if(r)
    80000b00:	c885                	beqz	s1,80000b30 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b02:	609c                	ld	a5,0(s1)
    80000b04:	00010517          	auipc	a0,0x10
    80000b08:	00c50513          	addi	a0,a0,12 # 80010b10 <kmem>
    80000b0c:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b0e:	00000097          	auipc	ra,0x0
    80000b12:	178080e7          	jalr	376(ra) # 80000c86 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b16:	6605                	lui	a2,0x1
    80000b18:	4595                	li	a1,5
    80000b1a:	8526                	mv	a0,s1
    80000b1c:	00000097          	auipc	ra,0x0
    80000b20:	1b2080e7          	jalr	434(ra) # 80000cce <memset>
  return (void*)r;
}
    80000b24:	8526                	mv	a0,s1
    80000b26:	60e2                	ld	ra,24(sp)
    80000b28:	6442                	ld	s0,16(sp)
    80000b2a:	64a2                	ld	s1,8(sp)
    80000b2c:	6105                	addi	sp,sp,32
    80000b2e:	8082                	ret
  release(&kmem.lock);
    80000b30:	00010517          	auipc	a0,0x10
    80000b34:	fe050513          	addi	a0,a0,-32 # 80010b10 <kmem>
    80000b38:	00000097          	auipc	ra,0x0
    80000b3c:	14e080e7          	jalr	334(ra) # 80000c86 <release>
  if(r)
    80000b40:	b7d5                	j	80000b24 <kalloc+0x42>

0000000080000b42 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b42:	1141                	addi	sp,sp,-16
    80000b44:	e422                	sd	s0,8(sp)
    80000b46:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b48:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4a:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b4e:	00053823          	sd	zero,16(a0)
}
    80000b52:	6422                	ld	s0,8(sp)
    80000b54:	0141                	addi	sp,sp,16
    80000b56:	8082                	ret

0000000080000b58 <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b58:	411c                	lw	a5,0(a0)
    80000b5a:	e399                	bnez	a5,80000b60 <holding+0x8>
    80000b5c:	4501                	li	a0,0
  return r;
}
    80000b5e:	8082                	ret
{
    80000b60:	1101                	addi	sp,sp,-32
    80000b62:	ec06                	sd	ra,24(sp)
    80000b64:	e822                	sd	s0,16(sp)
    80000b66:	e426                	sd	s1,8(sp)
    80000b68:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6a:	6904                	ld	s1,16(a0)
    80000b6c:	00001097          	auipc	ra,0x1
    80000b70:	e1e080e7          	jalr	-482(ra) # 8000198a <mycpu>
    80000b74:	40a48533          	sub	a0,s1,a0
    80000b78:	00153513          	seqz	a0,a0
}
    80000b7c:	60e2                	ld	ra,24(sp)
    80000b7e:	6442                	ld	s0,16(sp)
    80000b80:	64a2                	ld	s1,8(sp)
    80000b82:	6105                	addi	sp,sp,32
    80000b84:	8082                	ret

0000000080000b86 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b86:	1101                	addi	sp,sp,-32
    80000b88:	ec06                	sd	ra,24(sp)
    80000b8a:	e822                	sd	s0,16(sp)
    80000b8c:	e426                	sd	s1,8(sp)
    80000b8e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b90:	100024f3          	csrr	s1,sstatus
    80000b94:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b98:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9a:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000b9e:	00001097          	auipc	ra,0x1
    80000ba2:	dec080e7          	jalr	-532(ra) # 8000198a <mycpu>
    80000ba6:	5d3c                	lw	a5,120(a0)
    80000ba8:	cf89                	beqz	a5,80000bc2 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000baa:	00001097          	auipc	ra,0x1
    80000bae:	de0080e7          	jalr	-544(ra) # 8000198a <mycpu>
    80000bb2:	5d3c                	lw	a5,120(a0)
    80000bb4:	2785                	addiw	a5,a5,1
    80000bb6:	dd3c                	sw	a5,120(a0)
}
    80000bb8:	60e2                	ld	ra,24(sp)
    80000bba:	6442                	ld	s0,16(sp)
    80000bbc:	64a2                	ld	s1,8(sp)
    80000bbe:	6105                	addi	sp,sp,32
    80000bc0:	8082                	ret
    mycpu()->intena = old;
    80000bc2:	00001097          	auipc	ra,0x1
    80000bc6:	dc8080e7          	jalr	-568(ra) # 8000198a <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bca:	8085                	srli	s1,s1,0x1
    80000bcc:	8885                	andi	s1,s1,1
    80000bce:	dd64                	sw	s1,124(a0)
    80000bd0:	bfe9                	j	80000baa <push_off+0x24>

0000000080000bd2 <acquire>:
{
    80000bd2:	1101                	addi	sp,sp,-32
    80000bd4:	ec06                	sd	ra,24(sp)
    80000bd6:	e822                	sd	s0,16(sp)
    80000bd8:	e426                	sd	s1,8(sp)
    80000bda:	1000                	addi	s0,sp,32
    80000bdc:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000bde:	00000097          	auipc	ra,0x0
    80000be2:	fa8080e7          	jalr	-88(ra) # 80000b86 <push_off>
  if(holding(lk))
    80000be6:	8526                	mv	a0,s1
    80000be8:	00000097          	auipc	ra,0x0
    80000bec:	f70080e7          	jalr	-144(ra) # 80000b58 <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf0:	4705                	li	a4,1
  if(holding(lk))
    80000bf2:	e115                	bnez	a0,80000c16 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	87ba                	mv	a5,a4
    80000bf6:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfa:	2781                	sext.w	a5,a5
    80000bfc:	ffe5                	bnez	a5,80000bf4 <acquire+0x22>
  __sync_synchronize();
    80000bfe:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c02:	00001097          	auipc	ra,0x1
    80000c06:	d88080e7          	jalr	-632(ra) # 8000198a <mycpu>
    80000c0a:	e888                	sd	a0,16(s1)
}
    80000c0c:	60e2                	ld	ra,24(sp)
    80000c0e:	6442                	ld	s0,16(sp)
    80000c10:	64a2                	ld	s1,8(sp)
    80000c12:	6105                	addi	sp,sp,32
    80000c14:	8082                	ret
    panic("acquire");
    80000c16:	00007517          	auipc	a0,0x7
    80000c1a:	45a50513          	addi	a0,a0,1114 # 80008070 <digits+0x30>
    80000c1e:	00000097          	auipc	ra,0x0
    80000c22:	91e080e7          	jalr	-1762(ra) # 8000053c <panic>

0000000080000c26 <pop_off>:

void
pop_off(void)
{
    80000c26:	1141                	addi	sp,sp,-16
    80000c28:	e406                	sd	ra,8(sp)
    80000c2a:	e022                	sd	s0,0(sp)
    80000c2c:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c2e:	00001097          	auipc	ra,0x1
    80000c32:	d5c080e7          	jalr	-676(ra) # 8000198a <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c36:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3a:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c3c:	e78d                	bnez	a5,80000c66 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c3e:	5d3c                	lw	a5,120(a0)
    80000c40:	02f05b63          	blez	a5,80000c76 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c44:	37fd                	addiw	a5,a5,-1
    80000c46:	0007871b          	sext.w	a4,a5
    80000c4a:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c4c:	eb09                	bnez	a4,80000c5e <pop_off+0x38>
    80000c4e:	5d7c                	lw	a5,124(a0)
    80000c50:	c799                	beqz	a5,80000c5e <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c52:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c56:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5a:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c5e:	60a2                	ld	ra,8(sp)
    80000c60:	6402                	ld	s0,0(sp)
    80000c62:	0141                	addi	sp,sp,16
    80000c64:	8082                	ret
    panic("pop_off - interruptible");
    80000c66:	00007517          	auipc	a0,0x7
    80000c6a:	41250513          	addi	a0,a0,1042 # 80008078 <digits+0x38>
    80000c6e:	00000097          	auipc	ra,0x0
    80000c72:	8ce080e7          	jalr	-1842(ra) # 8000053c <panic>
    panic("pop_off");
    80000c76:	00007517          	auipc	a0,0x7
    80000c7a:	41a50513          	addi	a0,a0,1050 # 80008090 <digits+0x50>
    80000c7e:	00000097          	auipc	ra,0x0
    80000c82:	8be080e7          	jalr	-1858(ra) # 8000053c <panic>

0000000080000c86 <release>:
{
    80000c86:	1101                	addi	sp,sp,-32
    80000c88:	ec06                	sd	ra,24(sp)
    80000c8a:	e822                	sd	s0,16(sp)
    80000c8c:	e426                	sd	s1,8(sp)
    80000c8e:	1000                	addi	s0,sp,32
    80000c90:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c92:	00000097          	auipc	ra,0x0
    80000c96:	ec6080e7          	jalr	-314(ra) # 80000b58 <holding>
    80000c9a:	c115                	beqz	a0,80000cbe <release+0x38>
  lk->cpu = 0;
    80000c9c:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca0:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca4:	0f50000f          	fence	iorw,ow
    80000ca8:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cac:	00000097          	auipc	ra,0x0
    80000cb0:	f7a080e7          	jalr	-134(ra) # 80000c26 <pop_off>
}
    80000cb4:	60e2                	ld	ra,24(sp)
    80000cb6:	6442                	ld	s0,16(sp)
    80000cb8:	64a2                	ld	s1,8(sp)
    80000cba:	6105                	addi	sp,sp,32
    80000cbc:	8082                	ret
    panic("release");
    80000cbe:	00007517          	auipc	a0,0x7
    80000cc2:	3da50513          	addi	a0,a0,986 # 80008098 <digits+0x58>
    80000cc6:	00000097          	auipc	ra,0x0
    80000cca:	876080e7          	jalr	-1930(ra) # 8000053c <panic>

0000000080000cce <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cce:	1141                	addi	sp,sp,-16
    80000cd0:	e422                	sd	s0,8(sp)
    80000cd2:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd4:	ca19                	beqz	a2,80000cea <memset+0x1c>
    80000cd6:	87aa                	mv	a5,a0
    80000cd8:	1602                	slli	a2,a2,0x20
    80000cda:	9201                	srli	a2,a2,0x20
    80000cdc:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce4:	0785                	addi	a5,a5,1
    80000ce6:	fee79de3          	bne	a5,a4,80000ce0 <memset+0x12>
  }
  return dst;
}
    80000cea:	6422                	ld	s0,8(sp)
    80000cec:	0141                	addi	sp,sp,16
    80000cee:	8082                	ret

0000000080000cf0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf0:	1141                	addi	sp,sp,-16
    80000cf2:	e422                	sd	s0,8(sp)
    80000cf4:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf6:	ca05                	beqz	a2,80000d26 <memcmp+0x36>
    80000cf8:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cfc:	1682                	slli	a3,a3,0x20
    80000cfe:	9281                	srli	a3,a3,0x20
    80000d00:	0685                	addi	a3,a3,1
    80000d02:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d04:	00054783          	lbu	a5,0(a0)
    80000d08:	0005c703          	lbu	a4,0(a1)
    80000d0c:	00e79863          	bne	a5,a4,80000d1c <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d10:	0505                	addi	a0,a0,1
    80000d12:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d14:	fed518e3          	bne	a0,a3,80000d04 <memcmp+0x14>
  }

  return 0;
    80000d18:	4501                	li	a0,0
    80000d1a:	a019                	j	80000d20 <memcmp+0x30>
      return *s1 - *s2;
    80000d1c:	40e7853b          	subw	a0,a5,a4
}
    80000d20:	6422                	ld	s0,8(sp)
    80000d22:	0141                	addi	sp,sp,16
    80000d24:	8082                	ret
  return 0;
    80000d26:	4501                	li	a0,0
    80000d28:	bfe5                	j	80000d20 <memcmp+0x30>

0000000080000d2a <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2a:	1141                	addi	sp,sp,-16
    80000d2c:	e422                	sd	s0,8(sp)
    80000d2e:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d30:	c205                	beqz	a2,80000d50 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d32:	02a5e263          	bltu	a1,a0,80000d56 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d36:	1602                	slli	a2,a2,0x20
    80000d38:	9201                	srli	a2,a2,0x20
    80000d3a:	00c587b3          	add	a5,a1,a2
{
    80000d3e:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d40:	0585                	addi	a1,a1,1
    80000d42:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd2c1>
    80000d44:	fff5c683          	lbu	a3,-1(a1)
    80000d48:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d4c:	fef59ae3          	bne	a1,a5,80000d40 <memmove+0x16>

  return dst;
}
    80000d50:	6422                	ld	s0,8(sp)
    80000d52:	0141                	addi	sp,sp,16
    80000d54:	8082                	ret
  if(s < d && s + n > d){
    80000d56:	02061693          	slli	a3,a2,0x20
    80000d5a:	9281                	srli	a3,a3,0x20
    80000d5c:	00d58733          	add	a4,a1,a3
    80000d60:	fce57be3          	bgeu	a0,a4,80000d36 <memmove+0xc>
    d += n;
    80000d64:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d66:	fff6079b          	addiw	a5,a2,-1
    80000d6a:	1782                	slli	a5,a5,0x20
    80000d6c:	9381                	srli	a5,a5,0x20
    80000d6e:	fff7c793          	not	a5,a5
    80000d72:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d74:	177d                	addi	a4,a4,-1
    80000d76:	16fd                	addi	a3,a3,-1
    80000d78:	00074603          	lbu	a2,0(a4)
    80000d7c:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d80:	fee79ae3          	bne	a5,a4,80000d74 <memmove+0x4a>
    80000d84:	b7f1                	j	80000d50 <memmove+0x26>

0000000080000d86 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d86:	1141                	addi	sp,sp,-16
    80000d88:	e406                	sd	ra,8(sp)
    80000d8a:	e022                	sd	s0,0(sp)
    80000d8c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d8e:	00000097          	auipc	ra,0x0
    80000d92:	f9c080e7          	jalr	-100(ra) # 80000d2a <memmove>
}
    80000d96:	60a2                	ld	ra,8(sp)
    80000d98:	6402                	ld	s0,0(sp)
    80000d9a:	0141                	addi	sp,sp,16
    80000d9c:	8082                	ret

0000000080000d9e <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d9e:	1141                	addi	sp,sp,-16
    80000da0:	e422                	sd	s0,8(sp)
    80000da2:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da4:	ce11                	beqz	a2,80000dc0 <strncmp+0x22>
    80000da6:	00054783          	lbu	a5,0(a0)
    80000daa:	cf89                	beqz	a5,80000dc4 <strncmp+0x26>
    80000dac:	0005c703          	lbu	a4,0(a1)
    80000db0:	00f71a63          	bne	a4,a5,80000dc4 <strncmp+0x26>
    n--, p++, q++;
    80000db4:	367d                	addiw	a2,a2,-1
    80000db6:	0505                	addi	a0,a0,1
    80000db8:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dba:	f675                	bnez	a2,80000da6 <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dbc:	4501                	li	a0,0
    80000dbe:	a809                	j	80000dd0 <strncmp+0x32>
    80000dc0:	4501                	li	a0,0
    80000dc2:	a039                	j	80000dd0 <strncmp+0x32>
  if(n == 0)
    80000dc4:	ca09                	beqz	a2,80000dd6 <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dc6:	00054503          	lbu	a0,0(a0)
    80000dca:	0005c783          	lbu	a5,0(a1)
    80000dce:	9d1d                	subw	a0,a0,a5
}
    80000dd0:	6422                	ld	s0,8(sp)
    80000dd2:	0141                	addi	sp,sp,16
    80000dd4:	8082                	ret
    return 0;
    80000dd6:	4501                	li	a0,0
    80000dd8:	bfe5                	j	80000dd0 <strncmp+0x32>

0000000080000dda <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dda:	1141                	addi	sp,sp,-16
    80000ddc:	e422                	sd	s0,8(sp)
    80000dde:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de0:	87aa                	mv	a5,a0
    80000de2:	86b2                	mv	a3,a2
    80000de4:	367d                	addiw	a2,a2,-1
    80000de6:	00d05963          	blez	a3,80000df8 <strncpy+0x1e>
    80000dea:	0785                	addi	a5,a5,1
    80000dec:	0005c703          	lbu	a4,0(a1)
    80000df0:	fee78fa3          	sb	a4,-1(a5)
    80000df4:	0585                	addi	a1,a1,1
    80000df6:	f775                	bnez	a4,80000de2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000df8:	873e                	mv	a4,a5
    80000dfa:	9fb5                	addw	a5,a5,a3
    80000dfc:	37fd                	addiw	a5,a5,-1
    80000dfe:	00c05963          	blez	a2,80000e10 <strncpy+0x36>
    *s++ = 0;
    80000e02:	0705                	addi	a4,a4,1
    80000e04:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000e08:	40e786bb          	subw	a3,a5,a4
    80000e0c:	fed04be3          	bgtz	a3,80000e02 <strncpy+0x28>
  return os;
}
    80000e10:	6422                	ld	s0,8(sp)
    80000e12:	0141                	addi	sp,sp,16
    80000e14:	8082                	ret

0000000080000e16 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e16:	1141                	addi	sp,sp,-16
    80000e18:	e422                	sd	s0,8(sp)
    80000e1a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e1c:	02c05363          	blez	a2,80000e42 <safestrcpy+0x2c>
    80000e20:	fff6069b          	addiw	a3,a2,-1
    80000e24:	1682                	slli	a3,a3,0x20
    80000e26:	9281                	srli	a3,a3,0x20
    80000e28:	96ae                	add	a3,a3,a1
    80000e2a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e2c:	00d58963          	beq	a1,a3,80000e3e <safestrcpy+0x28>
    80000e30:	0585                	addi	a1,a1,1
    80000e32:	0785                	addi	a5,a5,1
    80000e34:	fff5c703          	lbu	a4,-1(a1)
    80000e38:	fee78fa3          	sb	a4,-1(a5)
    80000e3c:	fb65                	bnez	a4,80000e2c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e3e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e42:	6422                	ld	s0,8(sp)
    80000e44:	0141                	addi	sp,sp,16
    80000e46:	8082                	ret

0000000080000e48 <strlen>:

int
strlen(const char *s)
{
    80000e48:	1141                	addi	sp,sp,-16
    80000e4a:	e422                	sd	s0,8(sp)
    80000e4c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e4e:	00054783          	lbu	a5,0(a0)
    80000e52:	cf91                	beqz	a5,80000e6e <strlen+0x26>
    80000e54:	0505                	addi	a0,a0,1
    80000e56:	87aa                	mv	a5,a0
    80000e58:	86be                	mv	a3,a5
    80000e5a:	0785                	addi	a5,a5,1
    80000e5c:	fff7c703          	lbu	a4,-1(a5)
    80000e60:	ff65                	bnez	a4,80000e58 <strlen+0x10>
    80000e62:	40a6853b          	subw	a0,a3,a0
    80000e66:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e68:	6422                	ld	s0,8(sp)
    80000e6a:	0141                	addi	sp,sp,16
    80000e6c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e6e:	4501                	li	a0,0
    80000e70:	bfe5                	j	80000e68 <strlen+0x20>

0000000080000e72 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e72:	1141                	addi	sp,sp,-16
    80000e74:	e406                	sd	ra,8(sp)
    80000e76:	e022                	sd	s0,0(sp)
    80000e78:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e7a:	00001097          	auipc	ra,0x1
    80000e7e:	b00080e7          	jalr	-1280(ra) # 8000197a <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e82:	00008717          	auipc	a4,0x8
    80000e86:	a2670713          	addi	a4,a4,-1498 # 800088a8 <started>
  if(cpuid() == 0){
    80000e8a:	c139                	beqz	a0,80000ed0 <main+0x5e>
    while(started == 0)
    80000e8c:	431c                	lw	a5,0(a4)
    80000e8e:	2781                	sext.w	a5,a5
    80000e90:	dff5                	beqz	a5,80000e8c <main+0x1a>
      ;
    __sync_synchronize();
    80000e92:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e96:	00001097          	auipc	ra,0x1
    80000e9a:	ae4080e7          	jalr	-1308(ra) # 8000197a <cpuid>
    80000e9e:	85aa                	mv	a1,a0
    80000ea0:	00007517          	auipc	a0,0x7
    80000ea4:	21850513          	addi	a0,a0,536 # 800080b8 <digits+0x78>
    80000ea8:	fffff097          	auipc	ra,0xfffff
    80000eac:	6de080e7          	jalr	1758(ra) # 80000586 <printf>
    kvminithart();    // turn on paging
    80000eb0:	00000097          	auipc	ra,0x0
    80000eb4:	0d8080e7          	jalr	216(ra) # 80000f88 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000eb8:	00001097          	auipc	ra,0x1
    80000ebc:	78c080e7          	jalr	1932(ra) # 80002644 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec0:	00005097          	auipc	ra,0x5
    80000ec4:	cc0080e7          	jalr	-832(ra) # 80005b80 <plicinithart>
  }

  scheduler();        
    80000ec8:	00001097          	auipc	ra,0x1
    80000ecc:	fd4080e7          	jalr	-44(ra) # 80001e9c <scheduler>
    consoleinit();
    80000ed0:	fffff097          	auipc	ra,0xfffff
    80000ed4:	57c080e7          	jalr	1404(ra) # 8000044c <consoleinit>
    printfinit();
    80000ed8:	00000097          	auipc	ra,0x0
    80000edc:	88e080e7          	jalr	-1906(ra) # 80000766 <printfinit>
    printf("\n");
    80000ee0:	00007517          	auipc	a0,0x7
    80000ee4:	1e850513          	addi	a0,a0,488 # 800080c8 <digits+0x88>
    80000ee8:	fffff097          	auipc	ra,0xfffff
    80000eec:	69e080e7          	jalr	1694(ra) # 80000586 <printf>
    printf("xv6 kernel is booting\n");
    80000ef0:	00007517          	auipc	a0,0x7
    80000ef4:	1b050513          	addi	a0,a0,432 # 800080a0 <digits+0x60>
    80000ef8:	fffff097          	auipc	ra,0xfffff
    80000efc:	68e080e7          	jalr	1678(ra) # 80000586 <printf>
    printf("\n");
    80000f00:	00007517          	auipc	a0,0x7
    80000f04:	1c850513          	addi	a0,a0,456 # 800080c8 <digits+0x88>
    80000f08:	fffff097          	auipc	ra,0xfffff
    80000f0c:	67e080e7          	jalr	1662(ra) # 80000586 <printf>
    kinit();         // physical page allocator
    80000f10:	00000097          	auipc	ra,0x0
    80000f14:	b96080e7          	jalr	-1130(ra) # 80000aa6 <kinit>
    kvminit();       // create kernel page table
    80000f18:	00000097          	auipc	ra,0x0
    80000f1c:	326080e7          	jalr	806(ra) # 8000123e <kvminit>
    kvminithart();   // turn on paging
    80000f20:	00000097          	auipc	ra,0x0
    80000f24:	068080e7          	jalr	104(ra) # 80000f88 <kvminithart>
    procinit();      // process table
    80000f28:	00001097          	auipc	ra,0x1
    80000f2c:	99e080e7          	jalr	-1634(ra) # 800018c6 <procinit>
    trapinit();      // trap vectors
    80000f30:	00001097          	auipc	ra,0x1
    80000f34:	6ec080e7          	jalr	1772(ra) # 8000261c <trapinit>
    trapinithart();  // install kernel trap vector
    80000f38:	00001097          	auipc	ra,0x1
    80000f3c:	70c080e7          	jalr	1804(ra) # 80002644 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f40:	00005097          	auipc	ra,0x5
    80000f44:	c2a080e7          	jalr	-982(ra) # 80005b6a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f48:	00005097          	auipc	ra,0x5
    80000f4c:	c38080e7          	jalr	-968(ra) # 80005b80 <plicinithart>
    binit();         // buffer cache
    80000f50:	00002097          	auipc	ra,0x2
    80000f54:	e34080e7          	jalr	-460(ra) # 80002d84 <binit>
    iinit();         // inode table
    80000f58:	00002097          	auipc	ra,0x2
    80000f5c:	4d2080e7          	jalr	1234(ra) # 8000342a <iinit>
    fileinit();      // file table
    80000f60:	00003097          	auipc	ra,0x3
    80000f64:	448080e7          	jalr	1096(ra) # 800043a8 <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f68:	00005097          	auipc	ra,0x5
    80000f6c:	d20080e7          	jalr	-736(ra) # 80005c88 <virtio_disk_init>
    userinit();      // first user process
    80000f70:	00001097          	auipc	ra,0x1
    80000f74:	d0e080e7          	jalr	-754(ra) # 80001c7e <userinit>
    __sync_synchronize();
    80000f78:	0ff0000f          	fence
    started = 1;
    80000f7c:	4785                	li	a5,1
    80000f7e:	00008717          	auipc	a4,0x8
    80000f82:	92f72523          	sw	a5,-1750(a4) # 800088a8 <started>
    80000f86:	b789                	j	80000ec8 <main+0x56>

0000000080000f88 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f88:	1141                	addi	sp,sp,-16
    80000f8a:	e422                	sd	s0,8(sp)
    80000f8c:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f8e:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f92:	00008797          	auipc	a5,0x8
    80000f96:	91e7b783          	ld	a5,-1762(a5) # 800088b0 <kernel_pagetable>
    80000f9a:	83b1                	srli	a5,a5,0xc
    80000f9c:	577d                	li	a4,-1
    80000f9e:	177e                	slli	a4,a4,0x3f
    80000fa0:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa2:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fa6:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000faa:	6422                	ld	s0,8(sp)
    80000fac:	0141                	addi	sp,sp,16
    80000fae:	8082                	ret

0000000080000fb0 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb0:	7139                	addi	sp,sp,-64
    80000fb2:	fc06                	sd	ra,56(sp)
    80000fb4:	f822                	sd	s0,48(sp)
    80000fb6:	f426                	sd	s1,40(sp)
    80000fb8:	f04a                	sd	s2,32(sp)
    80000fba:	ec4e                	sd	s3,24(sp)
    80000fbc:	e852                	sd	s4,16(sp)
    80000fbe:	e456                	sd	s5,8(sp)
    80000fc0:	e05a                	sd	s6,0(sp)
    80000fc2:	0080                	addi	s0,sp,64
    80000fc4:	84aa                	mv	s1,a0
    80000fc6:	89ae                	mv	s3,a1
    80000fc8:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fca:	57fd                	li	a5,-1
    80000fcc:	83e9                	srli	a5,a5,0x1a
    80000fce:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd0:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd2:	04b7f263          	bgeu	a5,a1,80001016 <walk+0x66>
    panic("walk");
    80000fd6:	00007517          	auipc	a0,0x7
    80000fda:	0fa50513          	addi	a0,a0,250 # 800080d0 <digits+0x90>
    80000fde:	fffff097          	auipc	ra,0xfffff
    80000fe2:	55e080e7          	jalr	1374(ra) # 8000053c <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fe6:	060a8663          	beqz	s5,80001052 <walk+0xa2>
    80000fea:	00000097          	auipc	ra,0x0
    80000fee:	af8080e7          	jalr	-1288(ra) # 80000ae2 <kalloc>
    80000ff2:	84aa                	mv	s1,a0
    80000ff4:	c529                	beqz	a0,8000103e <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ff6:	6605                	lui	a2,0x1
    80000ff8:	4581                	li	a1,0
    80000ffa:	00000097          	auipc	ra,0x0
    80000ffe:	cd4080e7          	jalr	-812(ra) # 80000cce <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001002:	00c4d793          	srli	a5,s1,0xc
    80001006:	07aa                	slli	a5,a5,0xa
    80001008:	0017e793          	ori	a5,a5,1
    8000100c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001010:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd2b7>
    80001012:	036a0063          	beq	s4,s6,80001032 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    80001016:	0149d933          	srl	s2,s3,s4
    8000101a:	1ff97913          	andi	s2,s2,511
    8000101e:	090e                	slli	s2,s2,0x3
    80001020:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001022:	00093483          	ld	s1,0(s2)
    80001026:	0014f793          	andi	a5,s1,1
    8000102a:	dfd5                	beqz	a5,80000fe6 <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    8000102c:	80a9                	srli	s1,s1,0xa
    8000102e:	04b2                	slli	s1,s1,0xc
    80001030:	b7c5                	j	80001010 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001032:	00c9d513          	srli	a0,s3,0xc
    80001036:	1ff57513          	andi	a0,a0,511
    8000103a:	050e                	slli	a0,a0,0x3
    8000103c:	9526                	add	a0,a0,s1
}
    8000103e:	70e2                	ld	ra,56(sp)
    80001040:	7442                	ld	s0,48(sp)
    80001042:	74a2                	ld	s1,40(sp)
    80001044:	7902                	ld	s2,32(sp)
    80001046:	69e2                	ld	s3,24(sp)
    80001048:	6a42                	ld	s4,16(sp)
    8000104a:	6aa2                	ld	s5,8(sp)
    8000104c:	6b02                	ld	s6,0(sp)
    8000104e:	6121                	addi	sp,sp,64
    80001050:	8082                	ret
        return 0;
    80001052:	4501                	li	a0,0
    80001054:	b7ed                	j	8000103e <walk+0x8e>

0000000080001056 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80001056:	57fd                	li	a5,-1
    80001058:	83e9                	srli	a5,a5,0x1a
    8000105a:	00b7f463          	bgeu	a5,a1,80001062 <walkaddr+0xc>
    return 0;
    8000105e:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001060:	8082                	ret
{
    80001062:	1141                	addi	sp,sp,-16
    80001064:	e406                	sd	ra,8(sp)
    80001066:	e022                	sd	s0,0(sp)
    80001068:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000106a:	4601                	li	a2,0
    8000106c:	00000097          	auipc	ra,0x0
    80001070:	f44080e7          	jalr	-188(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001074:	c105                	beqz	a0,80001094 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    80001076:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80001078:	0117f693          	andi	a3,a5,17
    8000107c:	4745                	li	a4,17
    return 0;
    8000107e:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001080:	00e68663          	beq	a3,a4,8000108c <walkaddr+0x36>
}
    80001084:	60a2                	ld	ra,8(sp)
    80001086:	6402                	ld	s0,0(sp)
    80001088:	0141                	addi	sp,sp,16
    8000108a:	8082                	ret
  pa = PTE2PA(*pte);
    8000108c:	83a9                	srli	a5,a5,0xa
    8000108e:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001092:	bfcd                	j	80001084 <walkaddr+0x2e>
    return 0;
    80001094:	4501                	li	a0,0
    80001096:	b7fd                	j	80001084 <walkaddr+0x2e>

0000000080001098 <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001098:	715d                	addi	sp,sp,-80
    8000109a:	e486                	sd	ra,72(sp)
    8000109c:	e0a2                	sd	s0,64(sp)
    8000109e:	fc26                	sd	s1,56(sp)
    800010a0:	f84a                	sd	s2,48(sp)
    800010a2:	f44e                	sd	s3,40(sp)
    800010a4:	f052                	sd	s4,32(sp)
    800010a6:	ec56                	sd	s5,24(sp)
    800010a8:	e85a                	sd	s6,16(sp)
    800010aa:	e45e                	sd	s7,8(sp)
    800010ac:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010ae:	c639                	beqz	a2,800010fc <mappages+0x64>
    800010b0:	8aaa                	mv	s5,a0
    800010b2:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010b4:	777d                	lui	a4,0xfffff
    800010b6:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010ba:	fff58993          	addi	s3,a1,-1
    800010be:	99b2                	add	s3,s3,a2
    800010c0:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010c4:	893e                	mv	s2,a5
    800010c6:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010ca:	6b85                	lui	s7,0x1
    800010cc:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d0:	4605                	li	a2,1
    800010d2:	85ca                	mv	a1,s2
    800010d4:	8556                	mv	a0,s5
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	eda080e7          	jalr	-294(ra) # 80000fb0 <walk>
    800010de:	cd1d                	beqz	a0,8000111c <mappages+0x84>
    if(*pte & PTE_V)
    800010e0:	611c                	ld	a5,0(a0)
    800010e2:	8b85                	andi	a5,a5,1
    800010e4:	e785                	bnez	a5,8000110c <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010e6:	80b1                	srli	s1,s1,0xc
    800010e8:	04aa                	slli	s1,s1,0xa
    800010ea:	0164e4b3          	or	s1,s1,s6
    800010ee:	0014e493          	ori	s1,s1,1
    800010f2:	e104                	sd	s1,0(a0)
    if(a == last)
    800010f4:	05390063          	beq	s2,s3,80001134 <mappages+0x9c>
    a += PGSIZE;
    800010f8:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    800010fa:	bfc9                	j	800010cc <mappages+0x34>
    panic("mappages: size");
    800010fc:	00007517          	auipc	a0,0x7
    80001100:	fdc50513          	addi	a0,a0,-36 # 800080d8 <digits+0x98>
    80001104:	fffff097          	auipc	ra,0xfffff
    80001108:	438080e7          	jalr	1080(ra) # 8000053c <panic>
      panic("mappages: remap");
    8000110c:	00007517          	auipc	a0,0x7
    80001110:	fdc50513          	addi	a0,a0,-36 # 800080e8 <digits+0xa8>
    80001114:	fffff097          	auipc	ra,0xfffff
    80001118:	428080e7          	jalr	1064(ra) # 8000053c <panic>
      return -1;
    8000111c:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    8000111e:	60a6                	ld	ra,72(sp)
    80001120:	6406                	ld	s0,64(sp)
    80001122:	74e2                	ld	s1,56(sp)
    80001124:	7942                	ld	s2,48(sp)
    80001126:	79a2                	ld	s3,40(sp)
    80001128:	7a02                	ld	s4,32(sp)
    8000112a:	6ae2                	ld	s5,24(sp)
    8000112c:	6b42                	ld	s6,16(sp)
    8000112e:	6ba2                	ld	s7,8(sp)
    80001130:	6161                	addi	sp,sp,80
    80001132:	8082                	ret
  return 0;
    80001134:	4501                	li	a0,0
    80001136:	b7e5                	j	8000111e <mappages+0x86>

0000000080001138 <kvmmap>:
{
    80001138:	1141                	addi	sp,sp,-16
    8000113a:	e406                	sd	ra,8(sp)
    8000113c:	e022                	sd	s0,0(sp)
    8000113e:	0800                	addi	s0,sp,16
    80001140:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001142:	86b2                	mv	a3,a2
    80001144:	863e                	mv	a2,a5
    80001146:	00000097          	auipc	ra,0x0
    8000114a:	f52080e7          	jalr	-174(ra) # 80001098 <mappages>
    8000114e:	e509                	bnez	a0,80001158 <kvmmap+0x20>
}
    80001150:	60a2                	ld	ra,8(sp)
    80001152:	6402                	ld	s0,0(sp)
    80001154:	0141                	addi	sp,sp,16
    80001156:	8082                	ret
    panic("kvmmap");
    80001158:	00007517          	auipc	a0,0x7
    8000115c:	fa050513          	addi	a0,a0,-96 # 800080f8 <digits+0xb8>
    80001160:	fffff097          	auipc	ra,0xfffff
    80001164:	3dc080e7          	jalr	988(ra) # 8000053c <panic>

0000000080001168 <kvmmake>:
{
    80001168:	1101                	addi	sp,sp,-32
    8000116a:	ec06                	sd	ra,24(sp)
    8000116c:	e822                	sd	s0,16(sp)
    8000116e:	e426                	sd	s1,8(sp)
    80001170:	e04a                	sd	s2,0(sp)
    80001172:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80001174:	00000097          	auipc	ra,0x0
    80001178:	96e080e7          	jalr	-1682(ra) # 80000ae2 <kalloc>
    8000117c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000117e:	6605                	lui	a2,0x1
    80001180:	4581                	li	a1,0
    80001182:	00000097          	auipc	ra,0x0
    80001186:	b4c080e7          	jalr	-1204(ra) # 80000cce <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000118a:	4719                	li	a4,6
    8000118c:	6685                	lui	a3,0x1
    8000118e:	10000637          	lui	a2,0x10000
    80001192:	100005b7          	lui	a1,0x10000
    80001196:	8526                	mv	a0,s1
    80001198:	00000097          	auipc	ra,0x0
    8000119c:	fa0080e7          	jalr	-96(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a0:	4719                	li	a4,6
    800011a2:	6685                	lui	a3,0x1
    800011a4:	10001637          	lui	a2,0x10001
    800011a8:	100015b7          	lui	a1,0x10001
    800011ac:	8526                	mv	a0,s1
    800011ae:	00000097          	auipc	ra,0x0
    800011b2:	f8a080e7          	jalr	-118(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011b6:	4719                	li	a4,6
    800011b8:	004006b7          	lui	a3,0x400
    800011bc:	0c000637          	lui	a2,0xc000
    800011c0:	0c0005b7          	lui	a1,0xc000
    800011c4:	8526                	mv	a0,s1
    800011c6:	00000097          	auipc	ra,0x0
    800011ca:	f72080e7          	jalr	-142(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011ce:	00007917          	auipc	s2,0x7
    800011d2:	e3290913          	addi	s2,s2,-462 # 80008000 <etext>
    800011d6:	4729                	li	a4,10
    800011d8:	80007697          	auipc	a3,0x80007
    800011dc:	e2868693          	addi	a3,a3,-472 # 8000 <_entry-0x7fff8000>
    800011e0:	4605                	li	a2,1
    800011e2:	067e                	slli	a2,a2,0x1f
    800011e4:	85b2                	mv	a1,a2
    800011e6:	8526                	mv	a0,s1
    800011e8:	00000097          	auipc	ra,0x0
    800011ec:	f50080e7          	jalr	-176(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f0:	4719                	li	a4,6
    800011f2:	46c5                	li	a3,17
    800011f4:	06ee                	slli	a3,a3,0x1b
    800011f6:	412686b3          	sub	a3,a3,s2
    800011fa:	864a                	mv	a2,s2
    800011fc:	85ca                	mv	a1,s2
    800011fe:	8526                	mv	a0,s1
    80001200:	00000097          	auipc	ra,0x0
    80001204:	f38080e7          	jalr	-200(ra) # 80001138 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001208:	4729                	li	a4,10
    8000120a:	6685                	lui	a3,0x1
    8000120c:	00006617          	auipc	a2,0x6
    80001210:	df460613          	addi	a2,a2,-524 # 80007000 <_trampoline>
    80001214:	040005b7          	lui	a1,0x4000
    80001218:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    8000121a:	05b2                	slli	a1,a1,0xc
    8000121c:	8526                	mv	a0,s1
    8000121e:	00000097          	auipc	ra,0x0
    80001222:	f1a080e7          	jalr	-230(ra) # 80001138 <kvmmap>
  proc_mapstacks(kpgtbl);
    80001226:	8526                	mv	a0,s1
    80001228:	00000097          	auipc	ra,0x0
    8000122c:	608080e7          	jalr	1544(ra) # 80001830 <proc_mapstacks>
}
    80001230:	8526                	mv	a0,s1
    80001232:	60e2                	ld	ra,24(sp)
    80001234:	6442                	ld	s0,16(sp)
    80001236:	64a2                	ld	s1,8(sp)
    80001238:	6902                	ld	s2,0(sp)
    8000123a:	6105                	addi	sp,sp,32
    8000123c:	8082                	ret

000000008000123e <kvminit>:
{
    8000123e:	1141                	addi	sp,sp,-16
    80001240:	e406                	sd	ra,8(sp)
    80001242:	e022                	sd	s0,0(sp)
    80001244:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80001246:	00000097          	auipc	ra,0x0
    8000124a:	f22080e7          	jalr	-222(ra) # 80001168 <kvmmake>
    8000124e:	00007797          	auipc	a5,0x7
    80001252:	66a7b123          	sd	a0,1634(a5) # 800088b0 <kernel_pagetable>
}
    80001256:	60a2                	ld	ra,8(sp)
    80001258:	6402                	ld	s0,0(sp)
    8000125a:	0141                	addi	sp,sp,16
    8000125c:	8082                	ret

000000008000125e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000125e:	715d                	addi	sp,sp,-80
    80001260:	e486                	sd	ra,72(sp)
    80001262:	e0a2                	sd	s0,64(sp)
    80001264:	fc26                	sd	s1,56(sp)
    80001266:	f84a                	sd	s2,48(sp)
    80001268:	f44e                	sd	s3,40(sp)
    8000126a:	f052                	sd	s4,32(sp)
    8000126c:	ec56                	sd	s5,24(sp)
    8000126e:	e85a                	sd	s6,16(sp)
    80001270:	e45e                	sd	s7,8(sp)
    80001272:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80001274:	03459793          	slli	a5,a1,0x34
    80001278:	e795                	bnez	a5,800012a4 <uvmunmap+0x46>
    8000127a:	8a2a                	mv	s4,a0
    8000127c:	892e                	mv	s2,a1
    8000127e:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001280:	0632                	slli	a2,a2,0xc
    80001282:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    80001286:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001288:	6b05                	lui	s6,0x1
    8000128a:	0735e263          	bltu	a1,s3,800012ee <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    8000128e:	60a6                	ld	ra,72(sp)
    80001290:	6406                	ld	s0,64(sp)
    80001292:	74e2                	ld	s1,56(sp)
    80001294:	7942                	ld	s2,48(sp)
    80001296:	79a2                	ld	s3,40(sp)
    80001298:	7a02                	ld	s4,32(sp)
    8000129a:	6ae2                	ld	s5,24(sp)
    8000129c:	6b42                	ld	s6,16(sp)
    8000129e:	6ba2                	ld	s7,8(sp)
    800012a0:	6161                	addi	sp,sp,80
    800012a2:	8082                	ret
    panic("uvmunmap: not aligned");
    800012a4:	00007517          	auipc	a0,0x7
    800012a8:	e5c50513          	addi	a0,a0,-420 # 80008100 <digits+0xc0>
    800012ac:	fffff097          	auipc	ra,0xfffff
    800012b0:	290080e7          	jalr	656(ra) # 8000053c <panic>
      panic("uvmunmap: walk");
    800012b4:	00007517          	auipc	a0,0x7
    800012b8:	e6450513          	addi	a0,a0,-412 # 80008118 <digits+0xd8>
    800012bc:	fffff097          	auipc	ra,0xfffff
    800012c0:	280080e7          	jalr	640(ra) # 8000053c <panic>
      panic("uvmunmap: not mapped");
    800012c4:	00007517          	auipc	a0,0x7
    800012c8:	e6450513          	addi	a0,a0,-412 # 80008128 <digits+0xe8>
    800012cc:	fffff097          	auipc	ra,0xfffff
    800012d0:	270080e7          	jalr	624(ra) # 8000053c <panic>
      panic("uvmunmap: not a leaf");
    800012d4:	00007517          	auipc	a0,0x7
    800012d8:	e6c50513          	addi	a0,a0,-404 # 80008140 <digits+0x100>
    800012dc:	fffff097          	auipc	ra,0xfffff
    800012e0:	260080e7          	jalr	608(ra) # 8000053c <panic>
    *pte = 0;
    800012e4:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012e8:	995a                	add	s2,s2,s6
    800012ea:	fb3972e3          	bgeu	s2,s3,8000128e <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012ee:	4601                	li	a2,0
    800012f0:	85ca                	mv	a1,s2
    800012f2:	8552                	mv	a0,s4
    800012f4:	00000097          	auipc	ra,0x0
    800012f8:	cbc080e7          	jalr	-836(ra) # 80000fb0 <walk>
    800012fc:	84aa                	mv	s1,a0
    800012fe:	d95d                	beqz	a0,800012b4 <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001300:	6108                	ld	a0,0(a0)
    80001302:	00157793          	andi	a5,a0,1
    80001306:	dfdd                	beqz	a5,800012c4 <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    80001308:	3ff57793          	andi	a5,a0,1023
    8000130c:	fd7784e3          	beq	a5,s7,800012d4 <uvmunmap+0x76>
    if(do_free){
    80001310:	fc0a8ae3          	beqz	s5,800012e4 <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    80001314:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001316:	0532                	slli	a0,a0,0xc
    80001318:	fffff097          	auipc	ra,0xfffff
    8000131c:	6cc080e7          	jalr	1740(ra) # 800009e4 <kfree>
    80001320:	b7d1                	j	800012e4 <uvmunmap+0x86>

0000000080001322 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001322:	1101                	addi	sp,sp,-32
    80001324:	ec06                	sd	ra,24(sp)
    80001326:	e822                	sd	s0,16(sp)
    80001328:	e426                	sd	s1,8(sp)
    8000132a:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    8000132c:	fffff097          	auipc	ra,0xfffff
    80001330:	7b6080e7          	jalr	1974(ra) # 80000ae2 <kalloc>
    80001334:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001336:	c519                	beqz	a0,80001344 <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001338:	6605                	lui	a2,0x1
    8000133a:	4581                	li	a1,0
    8000133c:	00000097          	auipc	ra,0x0
    80001340:	992080e7          	jalr	-1646(ra) # 80000cce <memset>
  return pagetable;
}
    80001344:	8526                	mv	a0,s1
    80001346:	60e2                	ld	ra,24(sp)
    80001348:	6442                	ld	s0,16(sp)
    8000134a:	64a2                	ld	s1,8(sp)
    8000134c:	6105                	addi	sp,sp,32
    8000134e:	8082                	ret

0000000080001350 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001350:	7179                	addi	sp,sp,-48
    80001352:	f406                	sd	ra,40(sp)
    80001354:	f022                	sd	s0,32(sp)
    80001356:	ec26                	sd	s1,24(sp)
    80001358:	e84a                	sd	s2,16(sp)
    8000135a:	e44e                	sd	s3,8(sp)
    8000135c:	e052                	sd	s4,0(sp)
    8000135e:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001360:	6785                	lui	a5,0x1
    80001362:	04f67863          	bgeu	a2,a5,800013b2 <uvmfirst+0x62>
    80001366:	8a2a                	mv	s4,a0
    80001368:	89ae                	mv	s3,a1
    8000136a:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    8000136c:	fffff097          	auipc	ra,0xfffff
    80001370:	776080e7          	jalr	1910(ra) # 80000ae2 <kalloc>
    80001374:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    80001376:	6605                	lui	a2,0x1
    80001378:	4581                	li	a1,0
    8000137a:	00000097          	auipc	ra,0x0
    8000137e:	954080e7          	jalr	-1708(ra) # 80000cce <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001382:	4779                	li	a4,30
    80001384:	86ca                	mv	a3,s2
    80001386:	6605                	lui	a2,0x1
    80001388:	4581                	li	a1,0
    8000138a:	8552                	mv	a0,s4
    8000138c:	00000097          	auipc	ra,0x0
    80001390:	d0c080e7          	jalr	-756(ra) # 80001098 <mappages>
  memmove(mem, src, sz);
    80001394:	8626                	mv	a2,s1
    80001396:	85ce                	mv	a1,s3
    80001398:	854a                	mv	a0,s2
    8000139a:	00000097          	auipc	ra,0x0
    8000139e:	990080e7          	jalr	-1648(ra) # 80000d2a <memmove>
}
    800013a2:	70a2                	ld	ra,40(sp)
    800013a4:	7402                	ld	s0,32(sp)
    800013a6:	64e2                	ld	s1,24(sp)
    800013a8:	6942                	ld	s2,16(sp)
    800013aa:	69a2                	ld	s3,8(sp)
    800013ac:	6a02                	ld	s4,0(sp)
    800013ae:	6145                	addi	sp,sp,48
    800013b0:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b2:	00007517          	auipc	a0,0x7
    800013b6:	da650513          	addi	a0,a0,-602 # 80008158 <digits+0x118>
    800013ba:	fffff097          	auipc	ra,0xfffff
    800013be:	182080e7          	jalr	386(ra) # 8000053c <panic>

00000000800013c2 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c2:	1101                	addi	sp,sp,-32
    800013c4:	ec06                	sd	ra,24(sp)
    800013c6:	e822                	sd	s0,16(sp)
    800013c8:	e426                	sd	s1,8(sp)
    800013ca:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013cc:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013ce:	00b67d63          	bgeu	a2,a1,800013e8 <uvmdealloc+0x26>
    800013d2:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013d4:	6785                	lui	a5,0x1
    800013d6:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013d8:	00f60733          	add	a4,a2,a5
    800013dc:	76fd                	lui	a3,0xfffff
    800013de:	8f75                	and	a4,a4,a3
    800013e0:	97ae                	add	a5,a5,a1
    800013e2:	8ff5                	and	a5,a5,a3
    800013e4:	00f76863          	bltu	a4,a5,800013f4 <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013e8:	8526                	mv	a0,s1
    800013ea:	60e2                	ld	ra,24(sp)
    800013ec:	6442                	ld	s0,16(sp)
    800013ee:	64a2                	ld	s1,8(sp)
    800013f0:	6105                	addi	sp,sp,32
    800013f2:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013f4:	8f99                	sub	a5,a5,a4
    800013f6:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013f8:	4685                	li	a3,1
    800013fa:	0007861b          	sext.w	a2,a5
    800013fe:	85ba                	mv	a1,a4
    80001400:	00000097          	auipc	ra,0x0
    80001404:	e5e080e7          	jalr	-418(ra) # 8000125e <uvmunmap>
    80001408:	b7c5                	j	800013e8 <uvmdealloc+0x26>

000000008000140a <uvmalloc>:
  if(newsz < oldsz)
    8000140a:	0ab66563          	bltu	a2,a1,800014b4 <uvmalloc+0xaa>
{
    8000140e:	7139                	addi	sp,sp,-64
    80001410:	fc06                	sd	ra,56(sp)
    80001412:	f822                	sd	s0,48(sp)
    80001414:	f426                	sd	s1,40(sp)
    80001416:	f04a                	sd	s2,32(sp)
    80001418:	ec4e                	sd	s3,24(sp)
    8000141a:	e852                	sd	s4,16(sp)
    8000141c:	e456                	sd	s5,8(sp)
    8000141e:	e05a                	sd	s6,0(sp)
    80001420:	0080                	addi	s0,sp,64
    80001422:	8aaa                	mv	s5,a0
    80001424:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001426:	6785                	lui	a5,0x1
    80001428:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000142a:	95be                	add	a1,a1,a5
    8000142c:	77fd                	lui	a5,0xfffff
    8000142e:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001432:	08c9f363          	bgeu	s3,a2,800014b8 <uvmalloc+0xae>
    80001436:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001438:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    8000143c:	fffff097          	auipc	ra,0xfffff
    80001440:	6a6080e7          	jalr	1702(ra) # 80000ae2 <kalloc>
    80001444:	84aa                	mv	s1,a0
    if(mem == 0){
    80001446:	c51d                	beqz	a0,80001474 <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    80001448:	6605                	lui	a2,0x1
    8000144a:	4581                	li	a1,0
    8000144c:	00000097          	auipc	ra,0x0
    80001450:	882080e7          	jalr	-1918(ra) # 80000cce <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001454:	875a                	mv	a4,s6
    80001456:	86a6                	mv	a3,s1
    80001458:	6605                	lui	a2,0x1
    8000145a:	85ca                	mv	a1,s2
    8000145c:	8556                	mv	a0,s5
    8000145e:	00000097          	auipc	ra,0x0
    80001462:	c3a080e7          	jalr	-966(ra) # 80001098 <mappages>
    80001466:	e90d                	bnez	a0,80001498 <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001468:	6785                	lui	a5,0x1
    8000146a:	993e                	add	s2,s2,a5
    8000146c:	fd4968e3          	bltu	s2,s4,8000143c <uvmalloc+0x32>
  return newsz;
    80001470:	8552                	mv	a0,s4
    80001472:	a809                	j	80001484 <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    80001474:	864e                	mv	a2,s3
    80001476:	85ca                	mv	a1,s2
    80001478:	8556                	mv	a0,s5
    8000147a:	00000097          	auipc	ra,0x0
    8000147e:	f48080e7          	jalr	-184(ra) # 800013c2 <uvmdealloc>
      return 0;
    80001482:	4501                	li	a0,0
}
    80001484:	70e2                	ld	ra,56(sp)
    80001486:	7442                	ld	s0,48(sp)
    80001488:	74a2                	ld	s1,40(sp)
    8000148a:	7902                	ld	s2,32(sp)
    8000148c:	69e2                	ld	s3,24(sp)
    8000148e:	6a42                	ld	s4,16(sp)
    80001490:	6aa2                	ld	s5,8(sp)
    80001492:	6b02                	ld	s6,0(sp)
    80001494:	6121                	addi	sp,sp,64
    80001496:	8082                	ret
      kfree(mem);
    80001498:	8526                	mv	a0,s1
    8000149a:	fffff097          	auipc	ra,0xfffff
    8000149e:	54a080e7          	jalr	1354(ra) # 800009e4 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a2:	864e                	mv	a2,s3
    800014a4:	85ca                	mv	a1,s2
    800014a6:	8556                	mv	a0,s5
    800014a8:	00000097          	auipc	ra,0x0
    800014ac:	f1a080e7          	jalr	-230(ra) # 800013c2 <uvmdealloc>
      return 0;
    800014b0:	4501                	li	a0,0
    800014b2:	bfc9                	j	80001484 <uvmalloc+0x7a>
    return oldsz;
    800014b4:	852e                	mv	a0,a1
}
    800014b6:	8082                	ret
  return newsz;
    800014b8:	8532                	mv	a0,a2
    800014ba:	b7e9                	j	80001484 <uvmalloc+0x7a>

00000000800014bc <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014bc:	7179                	addi	sp,sp,-48
    800014be:	f406                	sd	ra,40(sp)
    800014c0:	f022                	sd	s0,32(sp)
    800014c2:	ec26                	sd	s1,24(sp)
    800014c4:	e84a                	sd	s2,16(sp)
    800014c6:	e44e                	sd	s3,8(sp)
    800014c8:	e052                	sd	s4,0(sp)
    800014ca:	1800                	addi	s0,sp,48
    800014cc:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014ce:	84aa                	mv	s1,a0
    800014d0:	6905                	lui	s2,0x1
    800014d2:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014d4:	4985                	li	s3,1
    800014d6:	a829                	j	800014f0 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014d8:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014da:	00c79513          	slli	a0,a5,0xc
    800014de:	00000097          	auipc	ra,0x0
    800014e2:	fde080e7          	jalr	-34(ra) # 800014bc <freewalk>
      pagetable[i] = 0;
    800014e6:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014ea:	04a1                	addi	s1,s1,8
    800014ec:	03248163          	beq	s1,s2,8000150e <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f0:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f2:	00f7f713          	andi	a4,a5,15
    800014f6:	ff3701e3          	beq	a4,s3,800014d8 <freewalk+0x1c>
    } else if(pte & PTE_V){
    800014fa:	8b85                	andi	a5,a5,1
    800014fc:	d7fd                	beqz	a5,800014ea <freewalk+0x2e>
      panic("freewalk: leaf");
    800014fe:	00007517          	auipc	a0,0x7
    80001502:	c7a50513          	addi	a0,a0,-902 # 80008178 <digits+0x138>
    80001506:	fffff097          	auipc	ra,0xfffff
    8000150a:	036080e7          	jalr	54(ra) # 8000053c <panic>
    }
  }
  kfree((void*)pagetable);
    8000150e:	8552                	mv	a0,s4
    80001510:	fffff097          	auipc	ra,0xfffff
    80001514:	4d4080e7          	jalr	1236(ra) # 800009e4 <kfree>
}
    80001518:	70a2                	ld	ra,40(sp)
    8000151a:	7402                	ld	s0,32(sp)
    8000151c:	64e2                	ld	s1,24(sp)
    8000151e:	6942                	ld	s2,16(sp)
    80001520:	69a2                	ld	s3,8(sp)
    80001522:	6a02                	ld	s4,0(sp)
    80001524:	6145                	addi	sp,sp,48
    80001526:	8082                	ret

0000000080001528 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001528:	1101                	addi	sp,sp,-32
    8000152a:	ec06                	sd	ra,24(sp)
    8000152c:	e822                	sd	s0,16(sp)
    8000152e:	e426                	sd	s1,8(sp)
    80001530:	1000                	addi	s0,sp,32
    80001532:	84aa                	mv	s1,a0
  if(sz > 0)
    80001534:	e999                	bnez	a1,8000154a <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001536:	8526                	mv	a0,s1
    80001538:	00000097          	auipc	ra,0x0
    8000153c:	f84080e7          	jalr	-124(ra) # 800014bc <freewalk>
}
    80001540:	60e2                	ld	ra,24(sp)
    80001542:	6442                	ld	s0,16(sp)
    80001544:	64a2                	ld	s1,8(sp)
    80001546:	6105                	addi	sp,sp,32
    80001548:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    8000154a:	6785                	lui	a5,0x1
    8000154c:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    8000154e:	95be                	add	a1,a1,a5
    80001550:	4685                	li	a3,1
    80001552:	00c5d613          	srli	a2,a1,0xc
    80001556:	4581                	li	a1,0
    80001558:	00000097          	auipc	ra,0x0
    8000155c:	d06080e7          	jalr	-762(ra) # 8000125e <uvmunmap>
    80001560:	bfd9                	j	80001536 <uvmfree+0xe>

0000000080001562 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001562:	c679                	beqz	a2,80001630 <uvmcopy+0xce>
{
    80001564:	715d                	addi	sp,sp,-80
    80001566:	e486                	sd	ra,72(sp)
    80001568:	e0a2                	sd	s0,64(sp)
    8000156a:	fc26                	sd	s1,56(sp)
    8000156c:	f84a                	sd	s2,48(sp)
    8000156e:	f44e                	sd	s3,40(sp)
    80001570:	f052                	sd	s4,32(sp)
    80001572:	ec56                	sd	s5,24(sp)
    80001574:	e85a                	sd	s6,16(sp)
    80001576:	e45e                	sd	s7,8(sp)
    80001578:	0880                	addi	s0,sp,80
    8000157a:	8b2a                	mv	s6,a0
    8000157c:	8aae                	mv	s5,a1
    8000157e:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001580:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001582:	4601                	li	a2,0
    80001584:	85ce                	mv	a1,s3
    80001586:	855a                	mv	a0,s6
    80001588:	00000097          	auipc	ra,0x0
    8000158c:	a28080e7          	jalr	-1496(ra) # 80000fb0 <walk>
    80001590:	c531                	beqz	a0,800015dc <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001592:	6118                	ld	a4,0(a0)
    80001594:	00177793          	andi	a5,a4,1
    80001598:	cbb1                	beqz	a5,800015ec <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    8000159a:	00a75593          	srli	a1,a4,0xa
    8000159e:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015a6:	fffff097          	auipc	ra,0xfffff
    800015aa:	53c080e7          	jalr	1340(ra) # 80000ae2 <kalloc>
    800015ae:	892a                	mv	s2,a0
    800015b0:	c939                	beqz	a0,80001606 <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b2:	6605                	lui	a2,0x1
    800015b4:	85de                	mv	a1,s7
    800015b6:	fffff097          	auipc	ra,0xfffff
    800015ba:	774080e7          	jalr	1908(ra) # 80000d2a <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015be:	8726                	mv	a4,s1
    800015c0:	86ca                	mv	a3,s2
    800015c2:	6605                	lui	a2,0x1
    800015c4:	85ce                	mv	a1,s3
    800015c6:	8556                	mv	a0,s5
    800015c8:	00000097          	auipc	ra,0x0
    800015cc:	ad0080e7          	jalr	-1328(ra) # 80001098 <mappages>
    800015d0:	e515                	bnez	a0,800015fc <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d2:	6785                	lui	a5,0x1
    800015d4:	99be                	add	s3,s3,a5
    800015d6:	fb49e6e3          	bltu	s3,s4,80001582 <uvmcopy+0x20>
    800015da:	a081                	j	8000161a <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015dc:	00007517          	auipc	a0,0x7
    800015e0:	bac50513          	addi	a0,a0,-1108 # 80008188 <digits+0x148>
    800015e4:	fffff097          	auipc	ra,0xfffff
    800015e8:	f58080e7          	jalr	-168(ra) # 8000053c <panic>
      panic("uvmcopy: page not present");
    800015ec:	00007517          	auipc	a0,0x7
    800015f0:	bbc50513          	addi	a0,a0,-1092 # 800081a8 <digits+0x168>
    800015f4:	fffff097          	auipc	ra,0xfffff
    800015f8:	f48080e7          	jalr	-184(ra) # 8000053c <panic>
      kfree(mem);
    800015fc:	854a                	mv	a0,s2
    800015fe:	fffff097          	auipc	ra,0xfffff
    80001602:	3e6080e7          	jalr	998(ra) # 800009e4 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80001606:	4685                	li	a3,1
    80001608:	00c9d613          	srli	a2,s3,0xc
    8000160c:	4581                	li	a1,0
    8000160e:	8556                	mv	a0,s5
    80001610:	00000097          	auipc	ra,0x0
    80001614:	c4e080e7          	jalr	-946(ra) # 8000125e <uvmunmap>
  return -1;
    80001618:	557d                	li	a0,-1
}
    8000161a:	60a6                	ld	ra,72(sp)
    8000161c:	6406                	ld	s0,64(sp)
    8000161e:	74e2                	ld	s1,56(sp)
    80001620:	7942                	ld	s2,48(sp)
    80001622:	79a2                	ld	s3,40(sp)
    80001624:	7a02                	ld	s4,32(sp)
    80001626:	6ae2                	ld	s5,24(sp)
    80001628:	6b42                	ld	s6,16(sp)
    8000162a:	6ba2                	ld	s7,8(sp)
    8000162c:	6161                	addi	sp,sp,80
    8000162e:	8082                	ret
  return 0;
    80001630:	4501                	li	a0,0
}
    80001632:	8082                	ret

0000000080001634 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001634:	1141                	addi	sp,sp,-16
    80001636:	e406                	sd	ra,8(sp)
    80001638:	e022                	sd	s0,0(sp)
    8000163a:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    8000163c:	4601                	li	a2,0
    8000163e:	00000097          	auipc	ra,0x0
    80001642:	972080e7          	jalr	-1678(ra) # 80000fb0 <walk>
  if(pte == 0)
    80001646:	c901                	beqz	a0,80001656 <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001648:	611c                	ld	a5,0(a0)
    8000164a:	9bbd                	andi	a5,a5,-17
    8000164c:	e11c                	sd	a5,0(a0)
}
    8000164e:	60a2                	ld	ra,8(sp)
    80001650:	6402                	ld	s0,0(sp)
    80001652:	0141                	addi	sp,sp,16
    80001654:	8082                	ret
    panic("uvmclear");
    80001656:	00007517          	auipc	a0,0x7
    8000165a:	b7250513          	addi	a0,a0,-1166 # 800081c8 <digits+0x188>
    8000165e:	fffff097          	auipc	ra,0xfffff
    80001662:	ede080e7          	jalr	-290(ra) # 8000053c <panic>

0000000080001666 <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001666:	c6bd                	beqz	a3,800016d4 <copyout+0x6e>
{
    80001668:	715d                	addi	sp,sp,-80
    8000166a:	e486                	sd	ra,72(sp)
    8000166c:	e0a2                	sd	s0,64(sp)
    8000166e:	fc26                	sd	s1,56(sp)
    80001670:	f84a                	sd	s2,48(sp)
    80001672:	f44e                	sd	s3,40(sp)
    80001674:	f052                	sd	s4,32(sp)
    80001676:	ec56                	sd	s5,24(sp)
    80001678:	e85a                	sd	s6,16(sp)
    8000167a:	e45e                	sd	s7,8(sp)
    8000167c:	e062                	sd	s8,0(sp)
    8000167e:	0880                	addi	s0,sp,80
    80001680:	8b2a                	mv	s6,a0
    80001682:	8c2e                	mv	s8,a1
    80001684:	8a32                	mv	s4,a2
    80001686:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80001688:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    8000168a:	6a85                	lui	s5,0x1
    8000168c:	a015                	j	800016b0 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    8000168e:	9562                	add	a0,a0,s8
    80001690:	0004861b          	sext.w	a2,s1
    80001694:	85d2                	mv	a1,s4
    80001696:	41250533          	sub	a0,a0,s2
    8000169a:	fffff097          	auipc	ra,0xfffff
    8000169e:	690080e7          	jalr	1680(ra) # 80000d2a <memmove>

    len -= n;
    800016a2:	409989b3          	sub	s3,s3,s1
    src += n;
    800016a6:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016a8:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016ac:	02098263          	beqz	s3,800016d0 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b0:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016b4:	85ca                	mv	a1,s2
    800016b6:	855a                	mv	a0,s6
    800016b8:	00000097          	auipc	ra,0x0
    800016bc:	99e080e7          	jalr	-1634(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800016c0:	cd01                	beqz	a0,800016d8 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c2:	418904b3          	sub	s1,s2,s8
    800016c6:	94d6                	add	s1,s1,s5
    800016c8:	fc99f3e3          	bgeu	s3,s1,8000168e <copyout+0x28>
    800016cc:	84ce                	mv	s1,s3
    800016ce:	b7c1                	j	8000168e <copyout+0x28>
  }
  return 0;
    800016d0:	4501                	li	a0,0
    800016d2:	a021                	j	800016da <copyout+0x74>
    800016d4:	4501                	li	a0,0
}
    800016d6:	8082                	ret
      return -1;
    800016d8:	557d                	li	a0,-1
}
    800016da:	60a6                	ld	ra,72(sp)
    800016dc:	6406                	ld	s0,64(sp)
    800016de:	74e2                	ld	s1,56(sp)
    800016e0:	7942                	ld	s2,48(sp)
    800016e2:	79a2                	ld	s3,40(sp)
    800016e4:	7a02                	ld	s4,32(sp)
    800016e6:	6ae2                	ld	s5,24(sp)
    800016e8:	6b42                	ld	s6,16(sp)
    800016ea:	6ba2                	ld	s7,8(sp)
    800016ec:	6c02                	ld	s8,0(sp)
    800016ee:	6161                	addi	sp,sp,80
    800016f0:	8082                	ret

00000000800016f2 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f2:	caa5                	beqz	a3,80001762 <copyin+0x70>
{
    800016f4:	715d                	addi	sp,sp,-80
    800016f6:	e486                	sd	ra,72(sp)
    800016f8:	e0a2                	sd	s0,64(sp)
    800016fa:	fc26                	sd	s1,56(sp)
    800016fc:	f84a                	sd	s2,48(sp)
    800016fe:	f44e                	sd	s3,40(sp)
    80001700:	f052                	sd	s4,32(sp)
    80001702:	ec56                	sd	s5,24(sp)
    80001704:	e85a                	sd	s6,16(sp)
    80001706:	e45e                	sd	s7,8(sp)
    80001708:	e062                	sd	s8,0(sp)
    8000170a:	0880                	addi	s0,sp,80
    8000170c:	8b2a                	mv	s6,a0
    8000170e:	8a2e                	mv	s4,a1
    80001710:	8c32                	mv	s8,a2
    80001712:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80001714:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80001716:	6a85                	lui	s5,0x1
    80001718:	a01d                	j	8000173e <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    8000171a:	018505b3          	add	a1,a0,s8
    8000171e:	0004861b          	sext.w	a2,s1
    80001722:	412585b3          	sub	a1,a1,s2
    80001726:	8552                	mv	a0,s4
    80001728:	fffff097          	auipc	ra,0xfffff
    8000172c:	602080e7          	jalr	1538(ra) # 80000d2a <memmove>

    len -= n;
    80001730:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001734:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001736:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000173a:	02098263          	beqz	s3,8000175e <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    8000173e:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001742:	85ca                	mv	a1,s2
    80001744:	855a                	mv	a0,s6
    80001746:	00000097          	auipc	ra,0x0
    8000174a:	910080e7          	jalr	-1776(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    8000174e:	cd01                	beqz	a0,80001766 <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001750:	418904b3          	sub	s1,s2,s8
    80001754:	94d6                	add	s1,s1,s5
    80001756:	fc99f2e3          	bgeu	s3,s1,8000171a <copyin+0x28>
    8000175a:	84ce                	mv	s1,s3
    8000175c:	bf7d                	j	8000171a <copyin+0x28>
  }
  return 0;
    8000175e:	4501                	li	a0,0
    80001760:	a021                	j	80001768 <copyin+0x76>
    80001762:	4501                	li	a0,0
}
    80001764:	8082                	ret
      return -1;
    80001766:	557d                	li	a0,-1
}
    80001768:	60a6                	ld	ra,72(sp)
    8000176a:	6406                	ld	s0,64(sp)
    8000176c:	74e2                	ld	s1,56(sp)
    8000176e:	7942                	ld	s2,48(sp)
    80001770:	79a2                	ld	s3,40(sp)
    80001772:	7a02                	ld	s4,32(sp)
    80001774:	6ae2                	ld	s5,24(sp)
    80001776:	6b42                	ld	s6,16(sp)
    80001778:	6ba2                	ld	s7,8(sp)
    8000177a:	6c02                	ld	s8,0(sp)
    8000177c:	6161                	addi	sp,sp,80
    8000177e:	8082                	ret

0000000080001780 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001780:	c2dd                	beqz	a3,80001826 <copyinstr+0xa6>
{
    80001782:	715d                	addi	sp,sp,-80
    80001784:	e486                	sd	ra,72(sp)
    80001786:	e0a2                	sd	s0,64(sp)
    80001788:	fc26                	sd	s1,56(sp)
    8000178a:	f84a                	sd	s2,48(sp)
    8000178c:	f44e                	sd	s3,40(sp)
    8000178e:	f052                	sd	s4,32(sp)
    80001790:	ec56                	sd	s5,24(sp)
    80001792:	e85a                	sd	s6,16(sp)
    80001794:	e45e                	sd	s7,8(sp)
    80001796:	0880                	addi	s0,sp,80
    80001798:	8a2a                	mv	s4,a0
    8000179a:	8b2e                	mv	s6,a1
    8000179c:	8bb2                	mv	s7,a2
    8000179e:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a0:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a2:	6985                	lui	s3,0x1
    800017a4:	a02d                	j	800017ce <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017a6:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017aa:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017ac:	37fd                	addiw	a5,a5,-1
    800017ae:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b2:	60a6                	ld	ra,72(sp)
    800017b4:	6406                	ld	s0,64(sp)
    800017b6:	74e2                	ld	s1,56(sp)
    800017b8:	7942                	ld	s2,48(sp)
    800017ba:	79a2                	ld	s3,40(sp)
    800017bc:	7a02                	ld	s4,32(sp)
    800017be:	6ae2                	ld	s5,24(sp)
    800017c0:	6b42                	ld	s6,16(sp)
    800017c2:	6ba2                	ld	s7,8(sp)
    800017c4:	6161                	addi	sp,sp,80
    800017c6:	8082                	ret
    srcva = va0 + PGSIZE;
    800017c8:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017cc:	c8a9                	beqz	s1,8000181e <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017ce:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d2:	85ca                	mv	a1,s2
    800017d4:	8552                	mv	a0,s4
    800017d6:	00000097          	auipc	ra,0x0
    800017da:	880080e7          	jalr	-1920(ra) # 80001056 <walkaddr>
    if(pa0 == 0)
    800017de:	c131                	beqz	a0,80001822 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e0:	417906b3          	sub	a3,s2,s7
    800017e4:	96ce                	add	a3,a3,s3
    800017e6:	00d4f363          	bgeu	s1,a3,800017ec <copyinstr+0x6c>
    800017ea:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017ec:	955e                	add	a0,a0,s7
    800017ee:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f2:	daf9                	beqz	a3,800017c8 <copyinstr+0x48>
    800017f4:	87da                	mv	a5,s6
    800017f6:	885a                	mv	a6,s6
      if(*p == '\0'){
    800017f8:	41650633          	sub	a2,a0,s6
    while(n > 0){
    800017fc:	96da                	add	a3,a3,s6
    800017fe:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001800:	00f60733          	add	a4,a2,a5
    80001804:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd2c0>
    80001808:	df59                	beqz	a4,800017a6 <copyinstr+0x26>
        *dst = *p;
    8000180a:	00e78023          	sb	a4,0(a5)
      dst++;
    8000180e:	0785                	addi	a5,a5,1
    while(n > 0){
    80001810:	fed797e3          	bne	a5,a3,800017fe <copyinstr+0x7e>
    80001814:	14fd                	addi	s1,s1,-1
    80001816:	94c2                	add	s1,s1,a6
      --max;
    80001818:	8c8d                	sub	s1,s1,a1
      dst++;
    8000181a:	8b3e                	mv	s6,a5
    8000181c:	b775                	j	800017c8 <copyinstr+0x48>
    8000181e:	4781                	li	a5,0
    80001820:	b771                	j	800017ac <copyinstr+0x2c>
      return -1;
    80001822:	557d                	li	a0,-1
    80001824:	b779                	j	800017b2 <copyinstr+0x32>
  int got_null = 0;
    80001826:	4781                	li	a5,0
  if(got_null){
    80001828:	37fd                	addiw	a5,a5,-1
    8000182a:	0007851b          	sext.w	a0,a5
}
    8000182e:	8082                	ret

0000000080001830 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001830:	7139                	addi	sp,sp,-64
    80001832:	fc06                	sd	ra,56(sp)
    80001834:	f822                	sd	s0,48(sp)
    80001836:	f426                	sd	s1,40(sp)
    80001838:	f04a                	sd	s2,32(sp)
    8000183a:	ec4e                	sd	s3,24(sp)
    8000183c:	e852                	sd	s4,16(sp)
    8000183e:	e456                	sd	s5,8(sp)
    80001840:	e05a                	sd	s6,0(sp)
    80001842:	0080                	addi	s0,sp,64
    80001844:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    80001846:	0000f497          	auipc	s1,0xf
    8000184a:	71a48493          	addi	s1,s1,1818 # 80010f60 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    8000184e:	8b26                	mv	s6,s1
    80001850:	00006a97          	auipc	s5,0x6
    80001854:	7b0a8a93          	addi	s5,s5,1968 # 80008000 <etext>
    80001858:	04000937          	lui	s2,0x4000
    8000185c:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000185e:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001860:	00015a17          	auipc	s4,0x15
    80001864:	100a0a13          	addi	s4,s4,256 # 80016960 <tickslock>
    char *pa = kalloc();
    80001868:	fffff097          	auipc	ra,0xfffff
    8000186c:	27a080e7          	jalr	634(ra) # 80000ae2 <kalloc>
    80001870:	862a                	mv	a2,a0
    if(pa == 0)
    80001872:	c131                	beqz	a0,800018b6 <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80001874:	416485b3          	sub	a1,s1,s6
    80001878:	858d                	srai	a1,a1,0x3
    8000187a:	000ab783          	ld	a5,0(s5)
    8000187e:	02f585b3          	mul	a1,a1,a5
    80001882:	2585                	addiw	a1,a1,1
    80001884:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80001888:	4719                	li	a4,6
    8000188a:	6685                	lui	a3,0x1
    8000188c:	40b905b3          	sub	a1,s2,a1
    80001890:	854e                	mv	a0,s3
    80001892:	00000097          	auipc	ra,0x0
    80001896:	8a6080e7          	jalr	-1882(ra) # 80001138 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000189a:	16848493          	addi	s1,s1,360
    8000189e:	fd4495e3          	bne	s1,s4,80001868 <proc_mapstacks+0x38>
  }
}
    800018a2:	70e2                	ld	ra,56(sp)
    800018a4:	7442                	ld	s0,48(sp)
    800018a6:	74a2                	ld	s1,40(sp)
    800018a8:	7902                	ld	s2,32(sp)
    800018aa:	69e2                	ld	s3,24(sp)
    800018ac:	6a42                	ld	s4,16(sp)
    800018ae:	6aa2                	ld	s5,8(sp)
    800018b0:	6b02                	ld	s6,0(sp)
    800018b2:	6121                	addi	sp,sp,64
    800018b4:	8082                	ret
      panic("kalloc");
    800018b6:	00007517          	auipc	a0,0x7
    800018ba:	92250513          	addi	a0,a0,-1758 # 800081d8 <digits+0x198>
    800018be:	fffff097          	auipc	ra,0xfffff
    800018c2:	c7e080e7          	jalr	-898(ra) # 8000053c <panic>

00000000800018c6 <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018c6:	7139                	addi	sp,sp,-64
    800018c8:	fc06                	sd	ra,56(sp)
    800018ca:	f822                	sd	s0,48(sp)
    800018cc:	f426                	sd	s1,40(sp)
    800018ce:	f04a                	sd	s2,32(sp)
    800018d0:	ec4e                	sd	s3,24(sp)
    800018d2:	e852                	sd	s4,16(sp)
    800018d4:	e456                	sd	s5,8(sp)
    800018d6:	e05a                	sd	s6,0(sp)
    800018d8:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018da:	00007597          	auipc	a1,0x7
    800018de:	90658593          	addi	a1,a1,-1786 # 800081e0 <digits+0x1a0>
    800018e2:	0000f517          	auipc	a0,0xf
    800018e6:	24e50513          	addi	a0,a0,590 # 80010b30 <pid_lock>
    800018ea:	fffff097          	auipc	ra,0xfffff
    800018ee:	258080e7          	jalr	600(ra) # 80000b42 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f2:	00007597          	auipc	a1,0x7
    800018f6:	8f658593          	addi	a1,a1,-1802 # 800081e8 <digits+0x1a8>
    800018fa:	0000f517          	auipc	a0,0xf
    800018fe:	24e50513          	addi	a0,a0,590 # 80010b48 <wait_lock>
    80001902:	fffff097          	auipc	ra,0xfffff
    80001906:	240080e7          	jalr	576(ra) # 80000b42 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000190a:	0000f497          	auipc	s1,0xf
    8000190e:	65648493          	addi	s1,s1,1622 # 80010f60 <proc>
      initlock(&p->lock, "proc");
    80001912:	00007b17          	auipc	s6,0x7
    80001916:	8e6b0b13          	addi	s6,s6,-1818 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000191a:	8aa6                	mv	s5,s1
    8000191c:	00006a17          	auipc	s4,0x6
    80001920:	6e4a0a13          	addi	s4,s4,1764 # 80008000 <etext>
    80001924:	04000937          	lui	s2,0x4000
    80001928:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    8000192a:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000192c:	00015997          	auipc	s3,0x15
    80001930:	03498993          	addi	s3,s3,52 # 80016960 <tickslock>
      initlock(&p->lock, "proc");
    80001934:	85da                	mv	a1,s6
    80001936:	8526                	mv	a0,s1
    80001938:	fffff097          	auipc	ra,0xfffff
    8000193c:	20a080e7          	jalr	522(ra) # 80000b42 <initlock>
      p->state = UNUSED;
    80001940:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001944:	415487b3          	sub	a5,s1,s5
    80001948:	878d                	srai	a5,a5,0x3
    8000194a:	000a3703          	ld	a4,0(s4)
    8000194e:	02e787b3          	mul	a5,a5,a4
    80001952:	2785                	addiw	a5,a5,1
    80001954:	00d7979b          	slliw	a5,a5,0xd
    80001958:	40f907b3          	sub	a5,s2,a5
    8000195c:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    8000195e:	16848493          	addi	s1,s1,360
    80001962:	fd3499e3          	bne	s1,s3,80001934 <procinit+0x6e>
  }
}
    80001966:	70e2                	ld	ra,56(sp)
    80001968:	7442                	ld	s0,48(sp)
    8000196a:	74a2                	ld	s1,40(sp)
    8000196c:	7902                	ld	s2,32(sp)
    8000196e:	69e2                	ld	s3,24(sp)
    80001970:	6a42                	ld	s4,16(sp)
    80001972:	6aa2                	ld	s5,8(sp)
    80001974:	6b02                	ld	s6,0(sp)
    80001976:	6121                	addi	sp,sp,64
    80001978:	8082                	ret

000000008000197a <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    8000197a:	1141                	addi	sp,sp,-16
    8000197c:	e422                	sd	s0,8(sp)
    8000197e:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001980:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001982:	2501                	sext.w	a0,a0
    80001984:	6422                	ld	s0,8(sp)
    80001986:	0141                	addi	sp,sp,16
    80001988:	8082                	ret

000000008000198a <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    8000198a:	1141                	addi	sp,sp,-16
    8000198c:	e422                	sd	s0,8(sp)
    8000198e:	0800                	addi	s0,sp,16
    80001990:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001992:	2781                	sext.w	a5,a5
    80001994:	079e                	slli	a5,a5,0x7
  return c;
}
    80001996:	0000f517          	auipc	a0,0xf
    8000199a:	1ca50513          	addi	a0,a0,458 # 80010b60 <cpus>
    8000199e:	953e                	add	a0,a0,a5
    800019a0:	6422                	ld	s0,8(sp)
    800019a2:	0141                	addi	sp,sp,16
    800019a4:	8082                	ret

00000000800019a6 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800019a6:	1101                	addi	sp,sp,-32
    800019a8:	ec06                	sd	ra,24(sp)
    800019aa:	e822                	sd	s0,16(sp)
    800019ac:	e426                	sd	s1,8(sp)
    800019ae:	1000                	addi	s0,sp,32
  push_off();
    800019b0:	fffff097          	auipc	ra,0xfffff
    800019b4:	1d6080e7          	jalr	470(ra) # 80000b86 <push_off>
    800019b8:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800019ba:	2781                	sext.w	a5,a5
    800019bc:	079e                	slli	a5,a5,0x7
    800019be:	0000f717          	auipc	a4,0xf
    800019c2:	17270713          	addi	a4,a4,370 # 80010b30 <pid_lock>
    800019c6:	97ba                	add	a5,a5,a4
    800019c8:	7b84                	ld	s1,48(a5)
  pop_off();
    800019ca:	fffff097          	auipc	ra,0xfffff
    800019ce:	25c080e7          	jalr	604(ra) # 80000c26 <pop_off>
  return p;
}
    800019d2:	8526                	mv	a0,s1
    800019d4:	60e2                	ld	ra,24(sp)
    800019d6:	6442                	ld	s0,16(sp)
    800019d8:	64a2                	ld	s1,8(sp)
    800019da:	6105                	addi	sp,sp,32
    800019dc:	8082                	ret

00000000800019de <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    800019de:	1141                	addi	sp,sp,-16
    800019e0:	e406                	sd	ra,8(sp)
    800019e2:	e022                	sd	s0,0(sp)
    800019e4:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    800019e6:	00000097          	auipc	ra,0x0
    800019ea:	fc0080e7          	jalr	-64(ra) # 800019a6 <myproc>
    800019ee:	fffff097          	auipc	ra,0xfffff
    800019f2:	298080e7          	jalr	664(ra) # 80000c86 <release>

  if (first) {
    800019f6:	00007797          	auipc	a5,0x7
    800019fa:	e4a7a783          	lw	a5,-438(a5) # 80008840 <first.1>
    800019fe:	eb89                	bnez	a5,80001a10 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001a00:	00001097          	auipc	ra,0x1
    80001a04:	c5c080e7          	jalr	-932(ra) # 8000265c <usertrapret>
}
    80001a08:	60a2                	ld	ra,8(sp)
    80001a0a:	6402                	ld	s0,0(sp)
    80001a0c:	0141                	addi	sp,sp,16
    80001a0e:	8082                	ret
    first = 0;
    80001a10:	00007797          	auipc	a5,0x7
    80001a14:	e207a823          	sw	zero,-464(a5) # 80008840 <first.1>
    fsinit(ROOTDEV);
    80001a18:	4505                	li	a0,1
    80001a1a:	00002097          	auipc	ra,0x2
    80001a1e:	990080e7          	jalr	-1648(ra) # 800033aa <fsinit>
    80001a22:	bff9                	j	80001a00 <forkret+0x22>

0000000080001a24 <allocpid>:
{
    80001a24:	1101                	addi	sp,sp,-32
    80001a26:	ec06                	sd	ra,24(sp)
    80001a28:	e822                	sd	s0,16(sp)
    80001a2a:	e426                	sd	s1,8(sp)
    80001a2c:	e04a                	sd	s2,0(sp)
    80001a2e:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001a30:	0000f917          	auipc	s2,0xf
    80001a34:	10090913          	addi	s2,s2,256 # 80010b30 <pid_lock>
    80001a38:	854a                	mv	a0,s2
    80001a3a:	fffff097          	auipc	ra,0xfffff
    80001a3e:	198080e7          	jalr	408(ra) # 80000bd2 <acquire>
  pid = nextpid;
    80001a42:	00007797          	auipc	a5,0x7
    80001a46:	e0278793          	addi	a5,a5,-510 # 80008844 <nextpid>
    80001a4a:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001a4c:	0014871b          	addiw	a4,s1,1
    80001a50:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001a52:	854a                	mv	a0,s2
    80001a54:	fffff097          	auipc	ra,0xfffff
    80001a58:	232080e7          	jalr	562(ra) # 80000c86 <release>
}
    80001a5c:	8526                	mv	a0,s1
    80001a5e:	60e2                	ld	ra,24(sp)
    80001a60:	6442                	ld	s0,16(sp)
    80001a62:	64a2                	ld	s1,8(sp)
    80001a64:	6902                	ld	s2,0(sp)
    80001a66:	6105                	addi	sp,sp,32
    80001a68:	8082                	ret

0000000080001a6a <proc_pagetable>:
{
    80001a6a:	1101                	addi	sp,sp,-32
    80001a6c:	ec06                	sd	ra,24(sp)
    80001a6e:	e822                	sd	s0,16(sp)
    80001a70:	e426                	sd	s1,8(sp)
    80001a72:	e04a                	sd	s2,0(sp)
    80001a74:	1000                	addi	s0,sp,32
    80001a76:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001a78:	00000097          	auipc	ra,0x0
    80001a7c:	8aa080e7          	jalr	-1878(ra) # 80001322 <uvmcreate>
    80001a80:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001a82:	c121                	beqz	a0,80001ac2 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001a84:	4729                	li	a4,10
    80001a86:	00005697          	auipc	a3,0x5
    80001a8a:	57a68693          	addi	a3,a3,1402 # 80007000 <_trampoline>
    80001a8e:	6605                	lui	a2,0x1
    80001a90:	040005b7          	lui	a1,0x4000
    80001a94:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a96:	05b2                	slli	a1,a1,0xc
    80001a98:	fffff097          	auipc	ra,0xfffff
    80001a9c:	600080e7          	jalr	1536(ra) # 80001098 <mappages>
    80001aa0:	02054863          	bltz	a0,80001ad0 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001aa4:	4719                	li	a4,6
    80001aa6:	05893683          	ld	a3,88(s2)
    80001aaa:	6605                	lui	a2,0x1
    80001aac:	020005b7          	lui	a1,0x2000
    80001ab0:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001ab2:	05b6                	slli	a1,a1,0xd
    80001ab4:	8526                	mv	a0,s1
    80001ab6:	fffff097          	auipc	ra,0xfffff
    80001aba:	5e2080e7          	jalr	1506(ra) # 80001098 <mappages>
    80001abe:	02054163          	bltz	a0,80001ae0 <proc_pagetable+0x76>
}
    80001ac2:	8526                	mv	a0,s1
    80001ac4:	60e2                	ld	ra,24(sp)
    80001ac6:	6442                	ld	s0,16(sp)
    80001ac8:	64a2                	ld	s1,8(sp)
    80001aca:	6902                	ld	s2,0(sp)
    80001acc:	6105                	addi	sp,sp,32
    80001ace:	8082                	ret
    uvmfree(pagetable, 0);
    80001ad0:	4581                	li	a1,0
    80001ad2:	8526                	mv	a0,s1
    80001ad4:	00000097          	auipc	ra,0x0
    80001ad8:	a54080e7          	jalr	-1452(ra) # 80001528 <uvmfree>
    return 0;
    80001adc:	4481                	li	s1,0
    80001ade:	b7d5                	j	80001ac2 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001ae0:	4681                	li	a3,0
    80001ae2:	4605                	li	a2,1
    80001ae4:	040005b7          	lui	a1,0x4000
    80001ae8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001aea:	05b2                	slli	a1,a1,0xc
    80001aec:	8526                	mv	a0,s1
    80001aee:	fffff097          	auipc	ra,0xfffff
    80001af2:	770080e7          	jalr	1904(ra) # 8000125e <uvmunmap>
    uvmfree(pagetable, 0);
    80001af6:	4581                	li	a1,0
    80001af8:	8526                	mv	a0,s1
    80001afa:	00000097          	auipc	ra,0x0
    80001afe:	a2e080e7          	jalr	-1490(ra) # 80001528 <uvmfree>
    return 0;
    80001b02:	4481                	li	s1,0
    80001b04:	bf7d                	j	80001ac2 <proc_pagetable+0x58>

0000000080001b06 <proc_freepagetable>:
{
    80001b06:	1101                	addi	sp,sp,-32
    80001b08:	ec06                	sd	ra,24(sp)
    80001b0a:	e822                	sd	s0,16(sp)
    80001b0c:	e426                	sd	s1,8(sp)
    80001b0e:	e04a                	sd	s2,0(sp)
    80001b10:	1000                	addi	s0,sp,32
    80001b12:	84aa                	mv	s1,a0
    80001b14:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001b16:	4681                	li	a3,0
    80001b18:	4605                	li	a2,1
    80001b1a:	040005b7          	lui	a1,0x4000
    80001b1e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001b20:	05b2                	slli	a1,a1,0xc
    80001b22:	fffff097          	auipc	ra,0xfffff
    80001b26:	73c080e7          	jalr	1852(ra) # 8000125e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001b2a:	4681                	li	a3,0
    80001b2c:	4605                	li	a2,1
    80001b2e:	020005b7          	lui	a1,0x2000
    80001b32:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001b34:	05b6                	slli	a1,a1,0xd
    80001b36:	8526                	mv	a0,s1
    80001b38:	fffff097          	auipc	ra,0xfffff
    80001b3c:	726080e7          	jalr	1830(ra) # 8000125e <uvmunmap>
  uvmfree(pagetable, sz);
    80001b40:	85ca                	mv	a1,s2
    80001b42:	8526                	mv	a0,s1
    80001b44:	00000097          	auipc	ra,0x0
    80001b48:	9e4080e7          	jalr	-1564(ra) # 80001528 <uvmfree>
}
    80001b4c:	60e2                	ld	ra,24(sp)
    80001b4e:	6442                	ld	s0,16(sp)
    80001b50:	64a2                	ld	s1,8(sp)
    80001b52:	6902                	ld	s2,0(sp)
    80001b54:	6105                	addi	sp,sp,32
    80001b56:	8082                	ret

0000000080001b58 <freeproc>:
{
    80001b58:	1101                	addi	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	1000                	addi	s0,sp,32
    80001b62:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001b64:	6d28                	ld	a0,88(a0)
    80001b66:	c509                	beqz	a0,80001b70 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001b68:	fffff097          	auipc	ra,0xfffff
    80001b6c:	e7c080e7          	jalr	-388(ra) # 800009e4 <kfree>
  p->trapframe = 0;
    80001b70:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001b74:	68a8                	ld	a0,80(s1)
    80001b76:	c511                	beqz	a0,80001b82 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001b78:	64ac                	ld	a1,72(s1)
    80001b7a:	00000097          	auipc	ra,0x0
    80001b7e:	f8c080e7          	jalr	-116(ra) # 80001b06 <proc_freepagetable>
  p->pagetable = 0;
    80001b82:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001b86:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001b8a:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001b8e:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001b92:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001b96:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001b9a:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001b9e:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001ba2:	0004ac23          	sw	zero,24(s1)
}
    80001ba6:	60e2                	ld	ra,24(sp)
    80001ba8:	6442                	ld	s0,16(sp)
    80001baa:	64a2                	ld	s1,8(sp)
    80001bac:	6105                	addi	sp,sp,32
    80001bae:	8082                	ret

0000000080001bb0 <allocproc>:
{
    80001bb0:	1101                	addi	sp,sp,-32
    80001bb2:	ec06                	sd	ra,24(sp)
    80001bb4:	e822                	sd	s0,16(sp)
    80001bb6:	e426                	sd	s1,8(sp)
    80001bb8:	e04a                	sd	s2,0(sp)
    80001bba:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001bbc:	0000f497          	auipc	s1,0xf
    80001bc0:	3a448493          	addi	s1,s1,932 # 80010f60 <proc>
    80001bc4:	00015917          	auipc	s2,0x15
    80001bc8:	d9c90913          	addi	s2,s2,-612 # 80016960 <tickslock>
    acquire(&p->lock);
    80001bcc:	8526                	mv	a0,s1
    80001bce:	fffff097          	auipc	ra,0xfffff
    80001bd2:	004080e7          	jalr	4(ra) # 80000bd2 <acquire>
    if(p->state == UNUSED) {
    80001bd6:	4c9c                	lw	a5,24(s1)
    80001bd8:	cf81                	beqz	a5,80001bf0 <allocproc+0x40>
      release(&p->lock);
    80001bda:	8526                	mv	a0,s1
    80001bdc:	fffff097          	auipc	ra,0xfffff
    80001be0:	0aa080e7          	jalr	170(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001be4:	16848493          	addi	s1,s1,360
    80001be8:	ff2492e3          	bne	s1,s2,80001bcc <allocproc+0x1c>
  return 0;
    80001bec:	4481                	li	s1,0
    80001bee:	a889                	j	80001c40 <allocproc+0x90>
  p->pid = allocpid();
    80001bf0:	00000097          	auipc	ra,0x0
    80001bf4:	e34080e7          	jalr	-460(ra) # 80001a24 <allocpid>
    80001bf8:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001bfa:	4785                	li	a5,1
    80001bfc:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001bfe:	fffff097          	auipc	ra,0xfffff
    80001c02:	ee4080e7          	jalr	-284(ra) # 80000ae2 <kalloc>
    80001c06:	892a                	mv	s2,a0
    80001c08:	eca8                	sd	a0,88(s1)
    80001c0a:	c131                	beqz	a0,80001c4e <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001c0c:	8526                	mv	a0,s1
    80001c0e:	00000097          	auipc	ra,0x0
    80001c12:	e5c080e7          	jalr	-420(ra) # 80001a6a <proc_pagetable>
    80001c16:	892a                	mv	s2,a0
    80001c18:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001c1a:	c531                	beqz	a0,80001c66 <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001c1c:	07000613          	li	a2,112
    80001c20:	4581                	li	a1,0
    80001c22:	06048513          	addi	a0,s1,96
    80001c26:	fffff097          	auipc	ra,0xfffff
    80001c2a:	0a8080e7          	jalr	168(ra) # 80000cce <memset>
  p->context.ra = (uint64)forkret;
    80001c2e:	00000797          	auipc	a5,0x0
    80001c32:	db078793          	addi	a5,a5,-592 # 800019de <forkret>
    80001c36:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001c38:	60bc                	ld	a5,64(s1)
    80001c3a:	6705                	lui	a4,0x1
    80001c3c:	97ba                	add	a5,a5,a4
    80001c3e:	f4bc                	sd	a5,104(s1)
}
    80001c40:	8526                	mv	a0,s1
    80001c42:	60e2                	ld	ra,24(sp)
    80001c44:	6442                	ld	s0,16(sp)
    80001c46:	64a2                	ld	s1,8(sp)
    80001c48:	6902                	ld	s2,0(sp)
    80001c4a:	6105                	addi	sp,sp,32
    80001c4c:	8082                	ret
    freeproc(p);
    80001c4e:	8526                	mv	a0,s1
    80001c50:	00000097          	auipc	ra,0x0
    80001c54:	f08080e7          	jalr	-248(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c58:	8526                	mv	a0,s1
    80001c5a:	fffff097          	auipc	ra,0xfffff
    80001c5e:	02c080e7          	jalr	44(ra) # 80000c86 <release>
    return 0;
    80001c62:	84ca                	mv	s1,s2
    80001c64:	bff1                	j	80001c40 <allocproc+0x90>
    freeproc(p);
    80001c66:	8526                	mv	a0,s1
    80001c68:	00000097          	auipc	ra,0x0
    80001c6c:	ef0080e7          	jalr	-272(ra) # 80001b58 <freeproc>
    release(&p->lock);
    80001c70:	8526                	mv	a0,s1
    80001c72:	fffff097          	auipc	ra,0xfffff
    80001c76:	014080e7          	jalr	20(ra) # 80000c86 <release>
    return 0;
    80001c7a:	84ca                	mv	s1,s2
    80001c7c:	b7d1                	j	80001c40 <allocproc+0x90>

0000000080001c7e <userinit>:
{
    80001c7e:	1101                	addi	sp,sp,-32
    80001c80:	ec06                	sd	ra,24(sp)
    80001c82:	e822                	sd	s0,16(sp)
    80001c84:	e426                	sd	s1,8(sp)
    80001c86:	1000                	addi	s0,sp,32
  p = allocproc();
    80001c88:	00000097          	auipc	ra,0x0
    80001c8c:	f28080e7          	jalr	-216(ra) # 80001bb0 <allocproc>
    80001c90:	84aa                	mv	s1,a0
  initproc = p;
    80001c92:	00007797          	auipc	a5,0x7
    80001c96:	c2a7b323          	sd	a0,-986(a5) # 800088b8 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001c9a:	03400613          	li	a2,52
    80001c9e:	00007597          	auipc	a1,0x7
    80001ca2:	bb258593          	addi	a1,a1,-1102 # 80008850 <initcode>
    80001ca6:	6928                	ld	a0,80(a0)
    80001ca8:	fffff097          	auipc	ra,0xfffff
    80001cac:	6a8080e7          	jalr	1704(ra) # 80001350 <uvmfirst>
  p->sz = PGSIZE;
    80001cb0:	6785                	lui	a5,0x1
    80001cb2:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001cb4:	6cb8                	ld	a4,88(s1)
    80001cb6:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001cba:	6cb8                	ld	a4,88(s1)
    80001cbc:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001cbe:	4641                	li	a2,16
    80001cc0:	00006597          	auipc	a1,0x6
    80001cc4:	54058593          	addi	a1,a1,1344 # 80008200 <digits+0x1c0>
    80001cc8:	15848513          	addi	a0,s1,344
    80001ccc:	fffff097          	auipc	ra,0xfffff
    80001cd0:	14a080e7          	jalr	330(ra) # 80000e16 <safestrcpy>
  p->cwd = namei("/");
    80001cd4:	00006517          	auipc	a0,0x6
    80001cd8:	53c50513          	addi	a0,a0,1340 # 80008210 <digits+0x1d0>
    80001cdc:	00002097          	auipc	ra,0x2
    80001ce0:	0ec080e7          	jalr	236(ra) # 80003dc8 <namei>
    80001ce4:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001ce8:	478d                	li	a5,3
    80001cea:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001cec:	8526                	mv	a0,s1
    80001cee:	fffff097          	auipc	ra,0xfffff
    80001cf2:	f98080e7          	jalr	-104(ra) # 80000c86 <release>
}
    80001cf6:	60e2                	ld	ra,24(sp)
    80001cf8:	6442                	ld	s0,16(sp)
    80001cfa:	64a2                	ld	s1,8(sp)
    80001cfc:	6105                	addi	sp,sp,32
    80001cfe:	8082                	ret

0000000080001d00 <growproc>:
{
    80001d00:	1101                	addi	sp,sp,-32
    80001d02:	ec06                	sd	ra,24(sp)
    80001d04:	e822                	sd	s0,16(sp)
    80001d06:	e426                	sd	s1,8(sp)
    80001d08:	e04a                	sd	s2,0(sp)
    80001d0a:	1000                	addi	s0,sp,32
    80001d0c:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001d0e:	00000097          	auipc	ra,0x0
    80001d12:	c98080e7          	jalr	-872(ra) # 800019a6 <myproc>
    80001d16:	84aa                	mv	s1,a0
  sz = p->sz;
    80001d18:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001d1a:	01204c63          	bgtz	s2,80001d32 <growproc+0x32>
  } else if(n < 0){
    80001d1e:	02094663          	bltz	s2,80001d4a <growproc+0x4a>
  p->sz = sz;
    80001d22:	e4ac                	sd	a1,72(s1)
  return 0;
    80001d24:	4501                	li	a0,0
}
    80001d26:	60e2                	ld	ra,24(sp)
    80001d28:	6442                	ld	s0,16(sp)
    80001d2a:	64a2                	ld	s1,8(sp)
    80001d2c:	6902                	ld	s2,0(sp)
    80001d2e:	6105                	addi	sp,sp,32
    80001d30:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001d32:	4691                	li	a3,4
    80001d34:	00b90633          	add	a2,s2,a1
    80001d38:	6928                	ld	a0,80(a0)
    80001d3a:	fffff097          	auipc	ra,0xfffff
    80001d3e:	6d0080e7          	jalr	1744(ra) # 8000140a <uvmalloc>
    80001d42:	85aa                	mv	a1,a0
    80001d44:	fd79                	bnez	a0,80001d22 <growproc+0x22>
      return -1;
    80001d46:	557d                	li	a0,-1
    80001d48:	bff9                	j	80001d26 <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001d4a:	00b90633          	add	a2,s2,a1
    80001d4e:	6928                	ld	a0,80(a0)
    80001d50:	fffff097          	auipc	ra,0xfffff
    80001d54:	672080e7          	jalr	1650(ra) # 800013c2 <uvmdealloc>
    80001d58:	85aa                	mv	a1,a0
    80001d5a:	b7e1                	j	80001d22 <growproc+0x22>

0000000080001d5c <fork>:
{
    80001d5c:	7139                	addi	sp,sp,-64
    80001d5e:	fc06                	sd	ra,56(sp)
    80001d60:	f822                	sd	s0,48(sp)
    80001d62:	f426                	sd	s1,40(sp)
    80001d64:	f04a                	sd	s2,32(sp)
    80001d66:	ec4e                	sd	s3,24(sp)
    80001d68:	e852                	sd	s4,16(sp)
    80001d6a:	e456                	sd	s5,8(sp)
    80001d6c:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001d6e:	00000097          	auipc	ra,0x0
    80001d72:	c38080e7          	jalr	-968(ra) # 800019a6 <myproc>
    80001d76:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001d78:	00000097          	auipc	ra,0x0
    80001d7c:	e38080e7          	jalr	-456(ra) # 80001bb0 <allocproc>
    80001d80:	10050c63          	beqz	a0,80001e98 <fork+0x13c>
    80001d84:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001d86:	048ab603          	ld	a2,72(s5)
    80001d8a:	692c                	ld	a1,80(a0)
    80001d8c:	050ab503          	ld	a0,80(s5)
    80001d90:	fffff097          	auipc	ra,0xfffff
    80001d94:	7d2080e7          	jalr	2002(ra) # 80001562 <uvmcopy>
    80001d98:	04054863          	bltz	a0,80001de8 <fork+0x8c>
  np->sz = p->sz;
    80001d9c:	048ab783          	ld	a5,72(s5)
    80001da0:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001da4:	058ab683          	ld	a3,88(s5)
    80001da8:	87b6                	mv	a5,a3
    80001daa:	058a3703          	ld	a4,88(s4)
    80001dae:	12068693          	addi	a3,a3,288
    80001db2:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001db6:	6788                	ld	a0,8(a5)
    80001db8:	6b8c                	ld	a1,16(a5)
    80001dba:	6f90                	ld	a2,24(a5)
    80001dbc:	01073023          	sd	a6,0(a4)
    80001dc0:	e708                	sd	a0,8(a4)
    80001dc2:	eb0c                	sd	a1,16(a4)
    80001dc4:	ef10                	sd	a2,24(a4)
    80001dc6:	02078793          	addi	a5,a5,32
    80001dca:	02070713          	addi	a4,a4,32
    80001dce:	fed792e3          	bne	a5,a3,80001db2 <fork+0x56>
  np->trapframe->a0 = 0;
    80001dd2:	058a3783          	ld	a5,88(s4)
    80001dd6:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001dda:	0d0a8493          	addi	s1,s5,208
    80001dde:	0d0a0913          	addi	s2,s4,208
    80001de2:	150a8993          	addi	s3,s5,336
    80001de6:	a00d                	j	80001e08 <fork+0xac>
    freeproc(np);
    80001de8:	8552                	mv	a0,s4
    80001dea:	00000097          	auipc	ra,0x0
    80001dee:	d6e080e7          	jalr	-658(ra) # 80001b58 <freeproc>
    release(&np->lock);
    80001df2:	8552                	mv	a0,s4
    80001df4:	fffff097          	auipc	ra,0xfffff
    80001df8:	e92080e7          	jalr	-366(ra) # 80000c86 <release>
    return -1;
    80001dfc:	597d                	li	s2,-1
    80001dfe:	a059                	j	80001e84 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001e00:	04a1                	addi	s1,s1,8
    80001e02:	0921                	addi	s2,s2,8
    80001e04:	01348b63          	beq	s1,s3,80001e1a <fork+0xbe>
    if(p->ofile[i])
    80001e08:	6088                	ld	a0,0(s1)
    80001e0a:	d97d                	beqz	a0,80001e00 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001e0c:	00002097          	auipc	ra,0x2
    80001e10:	62e080e7          	jalr	1582(ra) # 8000443a <filedup>
    80001e14:	00a93023          	sd	a0,0(s2)
    80001e18:	b7e5                	j	80001e00 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001e1a:	150ab503          	ld	a0,336(s5)
    80001e1e:	00001097          	auipc	ra,0x1
    80001e22:	7c6080e7          	jalr	1990(ra) # 800035e4 <idup>
    80001e26:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001e2a:	4641                	li	a2,16
    80001e2c:	158a8593          	addi	a1,s5,344
    80001e30:	158a0513          	addi	a0,s4,344
    80001e34:	fffff097          	auipc	ra,0xfffff
    80001e38:	fe2080e7          	jalr	-30(ra) # 80000e16 <safestrcpy>
  pid = np->pid;
    80001e3c:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001e40:	8552                	mv	a0,s4
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	e44080e7          	jalr	-444(ra) # 80000c86 <release>
  acquire(&wait_lock);
    80001e4a:	0000f497          	auipc	s1,0xf
    80001e4e:	cfe48493          	addi	s1,s1,-770 # 80010b48 <wait_lock>
    80001e52:	8526                	mv	a0,s1
    80001e54:	fffff097          	auipc	ra,0xfffff
    80001e58:	d7e080e7          	jalr	-642(ra) # 80000bd2 <acquire>
  np->parent = p;
    80001e5c:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001e60:	8526                	mv	a0,s1
    80001e62:	fffff097          	auipc	ra,0xfffff
    80001e66:	e24080e7          	jalr	-476(ra) # 80000c86 <release>
  acquire(&np->lock);
    80001e6a:	8552                	mv	a0,s4
    80001e6c:	fffff097          	auipc	ra,0xfffff
    80001e70:	d66080e7          	jalr	-666(ra) # 80000bd2 <acquire>
  np->state = RUNNABLE;
    80001e74:	478d                	li	a5,3
    80001e76:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001e7a:	8552                	mv	a0,s4
    80001e7c:	fffff097          	auipc	ra,0xfffff
    80001e80:	e0a080e7          	jalr	-502(ra) # 80000c86 <release>
}
    80001e84:	854a                	mv	a0,s2
    80001e86:	70e2                	ld	ra,56(sp)
    80001e88:	7442                	ld	s0,48(sp)
    80001e8a:	74a2                	ld	s1,40(sp)
    80001e8c:	7902                	ld	s2,32(sp)
    80001e8e:	69e2                	ld	s3,24(sp)
    80001e90:	6a42                	ld	s4,16(sp)
    80001e92:	6aa2                	ld	s5,8(sp)
    80001e94:	6121                	addi	sp,sp,64
    80001e96:	8082                	ret
    return -1;
    80001e98:	597d                	li	s2,-1
    80001e9a:	b7ed                	j	80001e84 <fork+0x128>

0000000080001e9c <scheduler>:
{
    80001e9c:	7139                	addi	sp,sp,-64
    80001e9e:	fc06                	sd	ra,56(sp)
    80001ea0:	f822                	sd	s0,48(sp)
    80001ea2:	f426                	sd	s1,40(sp)
    80001ea4:	f04a                	sd	s2,32(sp)
    80001ea6:	ec4e                	sd	s3,24(sp)
    80001ea8:	e852                	sd	s4,16(sp)
    80001eaa:	e456                	sd	s5,8(sp)
    80001eac:	e05a                	sd	s6,0(sp)
    80001eae:	0080                	addi	s0,sp,64
    80001eb0:	8792                	mv	a5,tp
  int id = r_tp();
    80001eb2:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001eb4:	00779a93          	slli	s5,a5,0x7
    80001eb8:	0000f717          	auipc	a4,0xf
    80001ebc:	c7870713          	addi	a4,a4,-904 # 80010b30 <pid_lock>
    80001ec0:	9756                	add	a4,a4,s5
    80001ec2:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    80001ec6:	0000f717          	auipc	a4,0xf
    80001eca:	ca270713          	addi	a4,a4,-862 # 80010b68 <cpus+0x8>
    80001ece:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80001ed0:	498d                	li	s3,3
        p->state = RUNNING;
    80001ed2:	4b11                	li	s6,4
        c->proc = p;
    80001ed4:	079e                	slli	a5,a5,0x7
    80001ed6:	0000fa17          	auipc	s4,0xf
    80001eda:	c5aa0a13          	addi	s4,s4,-934 # 80010b30 <pid_lock>
    80001ede:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80001ee0:	00015917          	auipc	s2,0x15
    80001ee4:	a8090913          	addi	s2,s2,-1408 # 80016960 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001ee8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001eec:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001ef0:	10079073          	csrw	sstatus,a5
    80001ef4:	0000f497          	auipc	s1,0xf
    80001ef8:	06c48493          	addi	s1,s1,108 # 80010f60 <proc>
    80001efc:	a811                	j	80001f10 <scheduler+0x74>
      release(&p->lock);
    80001efe:	8526                	mv	a0,s1
    80001f00:	fffff097          	auipc	ra,0xfffff
    80001f04:	d86080e7          	jalr	-634(ra) # 80000c86 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001f08:	16848493          	addi	s1,s1,360
    80001f0c:	fd248ee3          	beq	s1,s2,80001ee8 <scheduler+0x4c>
      acquire(&p->lock);
    80001f10:	8526                	mv	a0,s1
    80001f12:	fffff097          	auipc	ra,0xfffff
    80001f16:	cc0080e7          	jalr	-832(ra) # 80000bd2 <acquire>
      if(p->state == RUNNABLE) {
    80001f1a:	4c9c                	lw	a5,24(s1)
    80001f1c:	ff3791e3          	bne	a5,s3,80001efe <scheduler+0x62>
        p->state = RUNNING;
    80001f20:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80001f24:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    80001f28:	06048593          	addi	a1,s1,96
    80001f2c:	8556                	mv	a0,s5
    80001f2e:	00000097          	auipc	ra,0x0
    80001f32:	684080e7          	jalr	1668(ra) # 800025b2 <swtch>
        c->proc = 0;
    80001f36:	020a3823          	sd	zero,48(s4)
    80001f3a:	b7d1                	j	80001efe <scheduler+0x62>

0000000080001f3c <sched>:
{
    80001f3c:	7179                	addi	sp,sp,-48
    80001f3e:	f406                	sd	ra,40(sp)
    80001f40:	f022                	sd	s0,32(sp)
    80001f42:	ec26                	sd	s1,24(sp)
    80001f44:	e84a                	sd	s2,16(sp)
    80001f46:	e44e                	sd	s3,8(sp)
    80001f48:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001f4a:	00000097          	auipc	ra,0x0
    80001f4e:	a5c080e7          	jalr	-1444(ra) # 800019a6 <myproc>
    80001f52:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001f54:	fffff097          	auipc	ra,0xfffff
    80001f58:	c04080e7          	jalr	-1020(ra) # 80000b58 <holding>
    80001f5c:	c93d                	beqz	a0,80001fd2 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f5e:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001f60:	2781                	sext.w	a5,a5
    80001f62:	079e                	slli	a5,a5,0x7
    80001f64:	0000f717          	auipc	a4,0xf
    80001f68:	bcc70713          	addi	a4,a4,-1076 # 80010b30 <pid_lock>
    80001f6c:	97ba                	add	a5,a5,a4
    80001f6e:	0a87a703          	lw	a4,168(a5)
    80001f72:	4785                	li	a5,1
    80001f74:	06f71763          	bne	a4,a5,80001fe2 <sched+0xa6>
  if(p->state == RUNNING)
    80001f78:	4c98                	lw	a4,24(s1)
    80001f7a:	4791                	li	a5,4
    80001f7c:	06f70b63          	beq	a4,a5,80001ff2 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001f80:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001f84:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001f86:	efb5                	bnez	a5,80002002 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001f88:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001f8a:	0000f917          	auipc	s2,0xf
    80001f8e:	ba690913          	addi	s2,s2,-1114 # 80010b30 <pid_lock>
    80001f92:	2781                	sext.w	a5,a5
    80001f94:	079e                	slli	a5,a5,0x7
    80001f96:	97ca                	add	a5,a5,s2
    80001f98:	0ac7a983          	lw	s3,172(a5)
    80001f9c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001f9e:	2781                	sext.w	a5,a5
    80001fa0:	079e                	slli	a5,a5,0x7
    80001fa2:	0000f597          	auipc	a1,0xf
    80001fa6:	bc658593          	addi	a1,a1,-1082 # 80010b68 <cpus+0x8>
    80001faa:	95be                	add	a1,a1,a5
    80001fac:	06048513          	addi	a0,s1,96
    80001fb0:	00000097          	auipc	ra,0x0
    80001fb4:	602080e7          	jalr	1538(ra) # 800025b2 <swtch>
    80001fb8:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001fba:	2781                	sext.w	a5,a5
    80001fbc:	079e                	slli	a5,a5,0x7
    80001fbe:	993e                	add	s2,s2,a5
    80001fc0:	0b392623          	sw	s3,172(s2)
}
    80001fc4:	70a2                	ld	ra,40(sp)
    80001fc6:	7402                	ld	s0,32(sp)
    80001fc8:	64e2                	ld	s1,24(sp)
    80001fca:	6942                	ld	s2,16(sp)
    80001fcc:	69a2                	ld	s3,8(sp)
    80001fce:	6145                	addi	sp,sp,48
    80001fd0:	8082                	ret
    panic("sched p->lock");
    80001fd2:	00006517          	auipc	a0,0x6
    80001fd6:	24650513          	addi	a0,a0,582 # 80008218 <digits+0x1d8>
    80001fda:	ffffe097          	auipc	ra,0xffffe
    80001fde:	562080e7          	jalr	1378(ra) # 8000053c <panic>
    panic("sched locks");
    80001fe2:	00006517          	auipc	a0,0x6
    80001fe6:	24650513          	addi	a0,a0,582 # 80008228 <digits+0x1e8>
    80001fea:	ffffe097          	auipc	ra,0xffffe
    80001fee:	552080e7          	jalr	1362(ra) # 8000053c <panic>
    panic("sched running");
    80001ff2:	00006517          	auipc	a0,0x6
    80001ff6:	24650513          	addi	a0,a0,582 # 80008238 <digits+0x1f8>
    80001ffa:	ffffe097          	auipc	ra,0xffffe
    80001ffe:	542080e7          	jalr	1346(ra) # 8000053c <panic>
    panic("sched interruptible");
    80002002:	00006517          	auipc	a0,0x6
    80002006:	24650513          	addi	a0,a0,582 # 80008248 <digits+0x208>
    8000200a:	ffffe097          	auipc	ra,0xffffe
    8000200e:	532080e7          	jalr	1330(ra) # 8000053c <panic>

0000000080002012 <yield>:
{
    80002012:	1101                	addi	sp,sp,-32
    80002014:	ec06                	sd	ra,24(sp)
    80002016:	e822                	sd	s0,16(sp)
    80002018:	e426                	sd	s1,8(sp)
    8000201a:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    8000201c:	00000097          	auipc	ra,0x0
    80002020:	98a080e7          	jalr	-1654(ra) # 800019a6 <myproc>
    80002024:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80002026:	fffff097          	auipc	ra,0xfffff
    8000202a:	bac080e7          	jalr	-1108(ra) # 80000bd2 <acquire>
  p->state = RUNNABLE;
    8000202e:	478d                	li	a5,3
    80002030:	cc9c                	sw	a5,24(s1)
  sched();
    80002032:	00000097          	auipc	ra,0x0
    80002036:	f0a080e7          	jalr	-246(ra) # 80001f3c <sched>
  release(&p->lock);
    8000203a:	8526                	mv	a0,s1
    8000203c:	fffff097          	auipc	ra,0xfffff
    80002040:	c4a080e7          	jalr	-950(ra) # 80000c86 <release>
}
    80002044:	60e2                	ld	ra,24(sp)
    80002046:	6442                	ld	s0,16(sp)
    80002048:	64a2                	ld	s1,8(sp)
    8000204a:	6105                	addi	sp,sp,32
    8000204c:	8082                	ret

000000008000204e <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    8000204e:	7179                	addi	sp,sp,-48
    80002050:	f406                	sd	ra,40(sp)
    80002052:	f022                	sd	s0,32(sp)
    80002054:	ec26                	sd	s1,24(sp)
    80002056:	e84a                	sd	s2,16(sp)
    80002058:	e44e                	sd	s3,8(sp)
    8000205a:	1800                	addi	s0,sp,48
    8000205c:	89aa                	mv	s3,a0
    8000205e:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002060:	00000097          	auipc	ra,0x0
    80002064:	946080e7          	jalr	-1722(ra) # 800019a6 <myproc>
    80002068:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    8000206a:	fffff097          	auipc	ra,0xfffff
    8000206e:	b68080e7          	jalr	-1176(ra) # 80000bd2 <acquire>
  release(lk);
    80002072:	854a                	mv	a0,s2
    80002074:	fffff097          	auipc	ra,0xfffff
    80002078:	c12080e7          	jalr	-1006(ra) # 80000c86 <release>

  // Go to sleep.
  p->chan = chan;
    8000207c:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80002080:	4789                	li	a5,2
    80002082:	cc9c                	sw	a5,24(s1)

  sched();
    80002084:	00000097          	auipc	ra,0x0
    80002088:	eb8080e7          	jalr	-328(ra) # 80001f3c <sched>

  // Tidy up.
  p->chan = 0;
    8000208c:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80002090:	8526                	mv	a0,s1
    80002092:	fffff097          	auipc	ra,0xfffff
    80002096:	bf4080e7          	jalr	-1036(ra) # 80000c86 <release>
  acquire(lk);
    8000209a:	854a                	mv	a0,s2
    8000209c:	fffff097          	auipc	ra,0xfffff
    800020a0:	b36080e7          	jalr	-1226(ra) # 80000bd2 <acquire>
}
    800020a4:	70a2                	ld	ra,40(sp)
    800020a6:	7402                	ld	s0,32(sp)
    800020a8:	64e2                	ld	s1,24(sp)
    800020aa:	6942                	ld	s2,16(sp)
    800020ac:	69a2                	ld	s3,8(sp)
    800020ae:	6145                	addi	sp,sp,48
    800020b0:	8082                	ret

00000000800020b2 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    800020b2:	7139                	addi	sp,sp,-64
    800020b4:	fc06                	sd	ra,56(sp)
    800020b6:	f822                	sd	s0,48(sp)
    800020b8:	f426                	sd	s1,40(sp)
    800020ba:	f04a                	sd	s2,32(sp)
    800020bc:	ec4e                	sd	s3,24(sp)
    800020be:	e852                	sd	s4,16(sp)
    800020c0:	e456                	sd	s5,8(sp)
    800020c2:	0080                	addi	s0,sp,64
    800020c4:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    800020c6:	0000f497          	auipc	s1,0xf
    800020ca:	e9a48493          	addi	s1,s1,-358 # 80010f60 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    800020ce:	4989                	li	s3,2
        p->state = RUNNABLE;
    800020d0:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    800020d2:	00015917          	auipc	s2,0x15
    800020d6:	88e90913          	addi	s2,s2,-1906 # 80016960 <tickslock>
    800020da:	a811                	j	800020ee <wakeup+0x3c>
      }
      release(&p->lock);
    800020dc:	8526                	mv	a0,s1
    800020de:	fffff097          	auipc	ra,0xfffff
    800020e2:	ba8080e7          	jalr	-1112(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800020e6:	16848493          	addi	s1,s1,360
    800020ea:	03248663          	beq	s1,s2,80002116 <wakeup+0x64>
    if(p != myproc()){
    800020ee:	00000097          	auipc	ra,0x0
    800020f2:	8b8080e7          	jalr	-1864(ra) # 800019a6 <myproc>
    800020f6:	fea488e3          	beq	s1,a0,800020e6 <wakeup+0x34>
      acquire(&p->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	fffff097          	auipc	ra,0xfffff
    80002100:	ad6080e7          	jalr	-1322(ra) # 80000bd2 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002104:	4c9c                	lw	a5,24(s1)
    80002106:	fd379be3          	bne	a5,s3,800020dc <wakeup+0x2a>
    8000210a:	709c                	ld	a5,32(s1)
    8000210c:	fd4798e3          	bne	a5,s4,800020dc <wakeup+0x2a>
        p->state = RUNNABLE;
    80002110:	0154ac23          	sw	s5,24(s1)
    80002114:	b7e1                	j	800020dc <wakeup+0x2a>
    }
  }
}
    80002116:	70e2                	ld	ra,56(sp)
    80002118:	7442                	ld	s0,48(sp)
    8000211a:	74a2                	ld	s1,40(sp)
    8000211c:	7902                	ld	s2,32(sp)
    8000211e:	69e2                	ld	s3,24(sp)
    80002120:	6a42                	ld	s4,16(sp)
    80002122:	6aa2                	ld	s5,8(sp)
    80002124:	6121                	addi	sp,sp,64
    80002126:	8082                	ret

0000000080002128 <reparent>:
{
    80002128:	7179                	addi	sp,sp,-48
    8000212a:	f406                	sd	ra,40(sp)
    8000212c:	f022                	sd	s0,32(sp)
    8000212e:	ec26                	sd	s1,24(sp)
    80002130:	e84a                	sd	s2,16(sp)
    80002132:	e44e                	sd	s3,8(sp)
    80002134:	e052                	sd	s4,0(sp)
    80002136:	1800                	addi	s0,sp,48
    80002138:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000213a:	0000f497          	auipc	s1,0xf
    8000213e:	e2648493          	addi	s1,s1,-474 # 80010f60 <proc>
      pp->parent = initproc;
    80002142:	00006a17          	auipc	s4,0x6
    80002146:	776a0a13          	addi	s4,s4,1910 # 800088b8 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000214a:	00015997          	auipc	s3,0x15
    8000214e:	81698993          	addi	s3,s3,-2026 # 80016960 <tickslock>
    80002152:	a029                	j	8000215c <reparent+0x34>
    80002154:	16848493          	addi	s1,s1,360
    80002158:	01348d63          	beq	s1,s3,80002172 <reparent+0x4a>
    if(pp->parent == p){
    8000215c:	7c9c                	ld	a5,56(s1)
    8000215e:	ff279be3          	bne	a5,s2,80002154 <reparent+0x2c>
      pp->parent = initproc;
    80002162:	000a3503          	ld	a0,0(s4)
    80002166:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002168:	00000097          	auipc	ra,0x0
    8000216c:	f4a080e7          	jalr	-182(ra) # 800020b2 <wakeup>
    80002170:	b7d5                	j	80002154 <reparent+0x2c>
}
    80002172:	70a2                	ld	ra,40(sp)
    80002174:	7402                	ld	s0,32(sp)
    80002176:	64e2                	ld	s1,24(sp)
    80002178:	6942                	ld	s2,16(sp)
    8000217a:	69a2                	ld	s3,8(sp)
    8000217c:	6a02                	ld	s4,0(sp)
    8000217e:	6145                	addi	sp,sp,48
    80002180:	8082                	ret

0000000080002182 <exit>:
{
    80002182:	7179                	addi	sp,sp,-48
    80002184:	f406                	sd	ra,40(sp)
    80002186:	f022                	sd	s0,32(sp)
    80002188:	ec26                	sd	s1,24(sp)
    8000218a:	e84a                	sd	s2,16(sp)
    8000218c:	e44e                	sd	s3,8(sp)
    8000218e:	e052                	sd	s4,0(sp)
    80002190:	1800                	addi	s0,sp,48
    80002192:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    80002194:	00000097          	auipc	ra,0x0
    80002198:	812080e7          	jalr	-2030(ra) # 800019a6 <myproc>
    8000219c:	89aa                	mv	s3,a0
  if(p == initproc)
    8000219e:	00006797          	auipc	a5,0x6
    800021a2:	71a7b783          	ld	a5,1818(a5) # 800088b8 <initproc>
    800021a6:	0d050493          	addi	s1,a0,208
    800021aa:	15050913          	addi	s2,a0,336
    800021ae:	02a79363          	bne	a5,a0,800021d4 <exit+0x52>
    panic("init exiting");
    800021b2:	00006517          	auipc	a0,0x6
    800021b6:	0ae50513          	addi	a0,a0,174 # 80008260 <digits+0x220>
    800021ba:	ffffe097          	auipc	ra,0xffffe
    800021be:	382080e7          	jalr	898(ra) # 8000053c <panic>
      fileclose(f);
    800021c2:	00002097          	auipc	ra,0x2
    800021c6:	2ca080e7          	jalr	714(ra) # 8000448c <fileclose>
      p->ofile[fd] = 0;
    800021ca:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    800021ce:	04a1                	addi	s1,s1,8
    800021d0:	01248563          	beq	s1,s2,800021da <exit+0x58>
    if(p->ofile[fd]){
    800021d4:	6088                	ld	a0,0(s1)
    800021d6:	f575                	bnez	a0,800021c2 <exit+0x40>
    800021d8:	bfdd                	j	800021ce <exit+0x4c>
  begin_op();
    800021da:	00002097          	auipc	ra,0x2
    800021de:	dee080e7          	jalr	-530(ra) # 80003fc8 <begin_op>
  iput(p->cwd);
    800021e2:	1509b503          	ld	a0,336(s3)
    800021e6:	00001097          	auipc	ra,0x1
    800021ea:	5f6080e7          	jalr	1526(ra) # 800037dc <iput>
  end_op();
    800021ee:	00002097          	auipc	ra,0x2
    800021f2:	e54080e7          	jalr	-428(ra) # 80004042 <end_op>
  p->cwd = 0;
    800021f6:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    800021fa:	0000f497          	auipc	s1,0xf
    800021fe:	94e48493          	addi	s1,s1,-1714 # 80010b48 <wait_lock>
    80002202:	8526                	mv	a0,s1
    80002204:	fffff097          	auipc	ra,0xfffff
    80002208:	9ce080e7          	jalr	-1586(ra) # 80000bd2 <acquire>
  reparent(p);
    8000220c:	854e                	mv	a0,s3
    8000220e:	00000097          	auipc	ra,0x0
    80002212:	f1a080e7          	jalr	-230(ra) # 80002128 <reparent>
  wakeup(p->parent);
    80002216:	0389b503          	ld	a0,56(s3)
    8000221a:	00000097          	auipc	ra,0x0
    8000221e:	e98080e7          	jalr	-360(ra) # 800020b2 <wakeup>
  acquire(&p->lock);
    80002222:	854e                	mv	a0,s3
    80002224:	fffff097          	auipc	ra,0xfffff
    80002228:	9ae080e7          	jalr	-1618(ra) # 80000bd2 <acquire>
  p->xstate = status;
    8000222c:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002230:	4795                	li	a5,5
    80002232:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    80002236:	8526                	mv	a0,s1
    80002238:	fffff097          	auipc	ra,0xfffff
    8000223c:	a4e080e7          	jalr	-1458(ra) # 80000c86 <release>
  sched();
    80002240:	00000097          	auipc	ra,0x0
    80002244:	cfc080e7          	jalr	-772(ra) # 80001f3c <sched>
  panic("zombie exit");
    80002248:	00006517          	auipc	a0,0x6
    8000224c:	02850513          	addi	a0,a0,40 # 80008270 <digits+0x230>
    80002250:	ffffe097          	auipc	ra,0xffffe
    80002254:	2ec080e7          	jalr	748(ra) # 8000053c <panic>

0000000080002258 <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    80002258:	7179                	addi	sp,sp,-48
    8000225a:	f406                	sd	ra,40(sp)
    8000225c:	f022                	sd	s0,32(sp)
    8000225e:	ec26                	sd	s1,24(sp)
    80002260:	e84a                	sd	s2,16(sp)
    80002262:	e44e                	sd	s3,8(sp)
    80002264:	1800                	addi	s0,sp,48
    80002266:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    80002268:	0000f497          	auipc	s1,0xf
    8000226c:	cf848493          	addi	s1,s1,-776 # 80010f60 <proc>
    80002270:	00014997          	auipc	s3,0x14
    80002274:	6f098993          	addi	s3,s3,1776 # 80016960 <tickslock>
    acquire(&p->lock);
    80002278:	8526                	mv	a0,s1
    8000227a:	fffff097          	auipc	ra,0xfffff
    8000227e:	958080e7          	jalr	-1704(ra) # 80000bd2 <acquire>
    if(p->pid == pid){
    80002282:	589c                	lw	a5,48(s1)
    80002284:	01278d63          	beq	a5,s2,8000229e <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002288:	8526                	mv	a0,s1
    8000228a:	fffff097          	auipc	ra,0xfffff
    8000228e:	9fc080e7          	jalr	-1540(ra) # 80000c86 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80002292:	16848493          	addi	s1,s1,360
    80002296:	ff3491e3          	bne	s1,s3,80002278 <kill+0x20>
  }
  return -1;
    8000229a:	557d                	li	a0,-1
    8000229c:	a829                	j	800022b6 <kill+0x5e>
      p->killed = 1;
    8000229e:	4785                	li	a5,1
    800022a0:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800022a2:	4c98                	lw	a4,24(s1)
    800022a4:	4789                	li	a5,2
    800022a6:	00f70f63          	beq	a4,a5,800022c4 <kill+0x6c>
      release(&p->lock);
    800022aa:	8526                	mv	a0,s1
    800022ac:	fffff097          	auipc	ra,0xfffff
    800022b0:	9da080e7          	jalr	-1574(ra) # 80000c86 <release>
      return 0;
    800022b4:	4501                	li	a0,0
}
    800022b6:	70a2                	ld	ra,40(sp)
    800022b8:	7402                	ld	s0,32(sp)
    800022ba:	64e2                	ld	s1,24(sp)
    800022bc:	6942                	ld	s2,16(sp)
    800022be:	69a2                	ld	s3,8(sp)
    800022c0:	6145                	addi	sp,sp,48
    800022c2:	8082                	ret
        p->state = RUNNABLE;
    800022c4:	478d                	li	a5,3
    800022c6:	cc9c                	sw	a5,24(s1)
    800022c8:	b7cd                	j	800022aa <kill+0x52>

00000000800022ca <setkilled>:

void
setkilled(struct proc *p)
{
    800022ca:	1101                	addi	sp,sp,-32
    800022cc:	ec06                	sd	ra,24(sp)
    800022ce:	e822                	sd	s0,16(sp)
    800022d0:	e426                	sd	s1,8(sp)
    800022d2:	1000                	addi	s0,sp,32
    800022d4:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800022d6:	fffff097          	auipc	ra,0xfffff
    800022da:	8fc080e7          	jalr	-1796(ra) # 80000bd2 <acquire>
  p->killed = 1;
    800022de:	4785                	li	a5,1
    800022e0:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    800022e2:	8526                	mv	a0,s1
    800022e4:	fffff097          	auipc	ra,0xfffff
    800022e8:	9a2080e7          	jalr	-1630(ra) # 80000c86 <release>
}
    800022ec:	60e2                	ld	ra,24(sp)
    800022ee:	6442                	ld	s0,16(sp)
    800022f0:	64a2                	ld	s1,8(sp)
    800022f2:	6105                	addi	sp,sp,32
    800022f4:	8082                	ret

00000000800022f6 <killed>:

int
killed(struct proc *p)
{
    800022f6:	1101                	addi	sp,sp,-32
    800022f8:	ec06                	sd	ra,24(sp)
    800022fa:	e822                	sd	s0,16(sp)
    800022fc:	e426                	sd	s1,8(sp)
    800022fe:	e04a                	sd	s2,0(sp)
    80002300:	1000                	addi	s0,sp,32
    80002302:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002304:	fffff097          	auipc	ra,0xfffff
    80002308:	8ce080e7          	jalr	-1842(ra) # 80000bd2 <acquire>
  k = p->killed;
    8000230c:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002310:	8526                	mv	a0,s1
    80002312:	fffff097          	auipc	ra,0xfffff
    80002316:	974080e7          	jalr	-1676(ra) # 80000c86 <release>
  return k;
}
    8000231a:	854a                	mv	a0,s2
    8000231c:	60e2                	ld	ra,24(sp)
    8000231e:	6442                	ld	s0,16(sp)
    80002320:	64a2                	ld	s1,8(sp)
    80002322:	6902                	ld	s2,0(sp)
    80002324:	6105                	addi	sp,sp,32
    80002326:	8082                	ret

0000000080002328 <wait>:
{
    80002328:	715d                	addi	sp,sp,-80
    8000232a:	e486                	sd	ra,72(sp)
    8000232c:	e0a2                	sd	s0,64(sp)
    8000232e:	fc26                	sd	s1,56(sp)
    80002330:	f84a                	sd	s2,48(sp)
    80002332:	f44e                	sd	s3,40(sp)
    80002334:	f052                	sd	s4,32(sp)
    80002336:	ec56                	sd	s5,24(sp)
    80002338:	e85a                	sd	s6,16(sp)
    8000233a:	e45e                	sd	s7,8(sp)
    8000233c:	e062                	sd	s8,0(sp)
    8000233e:	0880                	addi	s0,sp,80
    80002340:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002342:	fffff097          	auipc	ra,0xfffff
    80002346:	664080e7          	jalr	1636(ra) # 800019a6 <myproc>
    8000234a:	892a                	mv	s2,a0
  acquire(&wait_lock);
    8000234c:	0000e517          	auipc	a0,0xe
    80002350:	7fc50513          	addi	a0,a0,2044 # 80010b48 <wait_lock>
    80002354:	fffff097          	auipc	ra,0xfffff
    80002358:	87e080e7          	jalr	-1922(ra) # 80000bd2 <acquire>
    havekids = 0;
    8000235c:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    8000235e:	4a15                	li	s4,5
        havekids = 1;
    80002360:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002362:	00014997          	auipc	s3,0x14
    80002366:	5fe98993          	addi	s3,s3,1534 # 80016960 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000236a:	0000ec17          	auipc	s8,0xe
    8000236e:	7dec0c13          	addi	s8,s8,2014 # 80010b48 <wait_lock>
    80002372:	a0d1                	j	80002436 <wait+0x10e>
          pid = pp->pid;
    80002374:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    80002378:	000b0e63          	beqz	s6,80002394 <wait+0x6c>
    8000237c:	4691                	li	a3,4
    8000237e:	02c48613          	addi	a2,s1,44
    80002382:	85da                	mv	a1,s6
    80002384:	05093503          	ld	a0,80(s2)
    80002388:	fffff097          	auipc	ra,0xfffff
    8000238c:	2de080e7          	jalr	734(ra) # 80001666 <copyout>
    80002390:	04054163          	bltz	a0,800023d2 <wait+0xaa>
          freeproc(pp);
    80002394:	8526                	mv	a0,s1
    80002396:	fffff097          	auipc	ra,0xfffff
    8000239a:	7c2080e7          	jalr	1986(ra) # 80001b58 <freeproc>
          release(&pp->lock);
    8000239e:	8526                	mv	a0,s1
    800023a0:	fffff097          	auipc	ra,0xfffff
    800023a4:	8e6080e7          	jalr	-1818(ra) # 80000c86 <release>
          release(&wait_lock);
    800023a8:	0000e517          	auipc	a0,0xe
    800023ac:	7a050513          	addi	a0,a0,1952 # 80010b48 <wait_lock>
    800023b0:	fffff097          	auipc	ra,0xfffff
    800023b4:	8d6080e7          	jalr	-1834(ra) # 80000c86 <release>
}
    800023b8:	854e                	mv	a0,s3
    800023ba:	60a6                	ld	ra,72(sp)
    800023bc:	6406                	ld	s0,64(sp)
    800023be:	74e2                	ld	s1,56(sp)
    800023c0:	7942                	ld	s2,48(sp)
    800023c2:	79a2                	ld	s3,40(sp)
    800023c4:	7a02                	ld	s4,32(sp)
    800023c6:	6ae2                	ld	s5,24(sp)
    800023c8:	6b42                	ld	s6,16(sp)
    800023ca:	6ba2                	ld	s7,8(sp)
    800023cc:	6c02                	ld	s8,0(sp)
    800023ce:	6161                	addi	sp,sp,80
    800023d0:	8082                	ret
            release(&pp->lock);
    800023d2:	8526                	mv	a0,s1
    800023d4:	fffff097          	auipc	ra,0xfffff
    800023d8:	8b2080e7          	jalr	-1870(ra) # 80000c86 <release>
            release(&wait_lock);
    800023dc:	0000e517          	auipc	a0,0xe
    800023e0:	76c50513          	addi	a0,a0,1900 # 80010b48 <wait_lock>
    800023e4:	fffff097          	auipc	ra,0xfffff
    800023e8:	8a2080e7          	jalr	-1886(ra) # 80000c86 <release>
            return -1;
    800023ec:	59fd                	li	s3,-1
    800023ee:	b7e9                	j	800023b8 <wait+0x90>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800023f0:	16848493          	addi	s1,s1,360
    800023f4:	03348463          	beq	s1,s3,8000241c <wait+0xf4>
      if(pp->parent == p){
    800023f8:	7c9c                	ld	a5,56(s1)
    800023fa:	ff279be3          	bne	a5,s2,800023f0 <wait+0xc8>
        acquire(&pp->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	ffffe097          	auipc	ra,0xffffe
    80002404:	7d2080e7          	jalr	2002(ra) # 80000bd2 <acquire>
        if(pp->state == ZOMBIE){
    80002408:	4c9c                	lw	a5,24(s1)
    8000240a:	f74785e3          	beq	a5,s4,80002374 <wait+0x4c>
        release(&pp->lock);
    8000240e:	8526                	mv	a0,s1
    80002410:	fffff097          	auipc	ra,0xfffff
    80002414:	876080e7          	jalr	-1930(ra) # 80000c86 <release>
        havekids = 1;
    80002418:	8756                	mv	a4,s5
    8000241a:	bfd9                	j	800023f0 <wait+0xc8>
    if(!havekids || killed(p)){
    8000241c:	c31d                	beqz	a4,80002442 <wait+0x11a>
    8000241e:	854a                	mv	a0,s2
    80002420:	00000097          	auipc	ra,0x0
    80002424:	ed6080e7          	jalr	-298(ra) # 800022f6 <killed>
    80002428:	ed09                	bnez	a0,80002442 <wait+0x11a>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000242a:	85e2                	mv	a1,s8
    8000242c:	854a                	mv	a0,s2
    8000242e:	00000097          	auipc	ra,0x0
    80002432:	c20080e7          	jalr	-992(ra) # 8000204e <sleep>
    havekids = 0;
    80002436:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002438:	0000f497          	auipc	s1,0xf
    8000243c:	b2848493          	addi	s1,s1,-1240 # 80010f60 <proc>
    80002440:	bf65                	j	800023f8 <wait+0xd0>
      release(&wait_lock);
    80002442:	0000e517          	auipc	a0,0xe
    80002446:	70650513          	addi	a0,a0,1798 # 80010b48 <wait_lock>
    8000244a:	fffff097          	auipc	ra,0xfffff
    8000244e:	83c080e7          	jalr	-1988(ra) # 80000c86 <release>
      return -1;
    80002452:	59fd                	li	s3,-1
    80002454:	b795                	j	800023b8 <wait+0x90>

0000000080002456 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002456:	7179                	addi	sp,sp,-48
    80002458:	f406                	sd	ra,40(sp)
    8000245a:	f022                	sd	s0,32(sp)
    8000245c:	ec26                	sd	s1,24(sp)
    8000245e:	e84a                	sd	s2,16(sp)
    80002460:	e44e                	sd	s3,8(sp)
    80002462:	e052                	sd	s4,0(sp)
    80002464:	1800                	addi	s0,sp,48
    80002466:	84aa                	mv	s1,a0
    80002468:	892e                	mv	s2,a1
    8000246a:	89b2                	mv	s3,a2
    8000246c:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    8000246e:	fffff097          	auipc	ra,0xfffff
    80002472:	538080e7          	jalr	1336(ra) # 800019a6 <myproc>
  if(user_dst){
    80002476:	c08d                	beqz	s1,80002498 <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    80002478:	86d2                	mv	a3,s4
    8000247a:	864e                	mv	a2,s3
    8000247c:	85ca                	mv	a1,s2
    8000247e:	6928                	ld	a0,80(a0)
    80002480:	fffff097          	auipc	ra,0xfffff
    80002484:	1e6080e7          	jalr	486(ra) # 80001666 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    80002488:	70a2                	ld	ra,40(sp)
    8000248a:	7402                	ld	s0,32(sp)
    8000248c:	64e2                	ld	s1,24(sp)
    8000248e:	6942                	ld	s2,16(sp)
    80002490:	69a2                	ld	s3,8(sp)
    80002492:	6a02                	ld	s4,0(sp)
    80002494:	6145                	addi	sp,sp,48
    80002496:	8082                	ret
    memmove((char *)dst, src, len);
    80002498:	000a061b          	sext.w	a2,s4
    8000249c:	85ce                	mv	a1,s3
    8000249e:	854a                	mv	a0,s2
    800024a0:	fffff097          	auipc	ra,0xfffff
    800024a4:	88a080e7          	jalr	-1910(ra) # 80000d2a <memmove>
    return 0;
    800024a8:	8526                	mv	a0,s1
    800024aa:	bff9                	j	80002488 <either_copyout+0x32>

00000000800024ac <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800024ac:	7179                	addi	sp,sp,-48
    800024ae:	f406                	sd	ra,40(sp)
    800024b0:	f022                	sd	s0,32(sp)
    800024b2:	ec26                	sd	s1,24(sp)
    800024b4:	e84a                	sd	s2,16(sp)
    800024b6:	e44e                	sd	s3,8(sp)
    800024b8:	e052                	sd	s4,0(sp)
    800024ba:	1800                	addi	s0,sp,48
    800024bc:	892a                	mv	s2,a0
    800024be:	84ae                	mv	s1,a1
    800024c0:	89b2                	mv	s3,a2
    800024c2:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800024c4:	fffff097          	auipc	ra,0xfffff
    800024c8:	4e2080e7          	jalr	1250(ra) # 800019a6 <myproc>
  if(user_src){
    800024cc:	c08d                	beqz	s1,800024ee <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800024ce:	86d2                	mv	a3,s4
    800024d0:	864e                	mv	a2,s3
    800024d2:	85ca                	mv	a1,s2
    800024d4:	6928                	ld	a0,80(a0)
    800024d6:	fffff097          	auipc	ra,0xfffff
    800024da:	21c080e7          	jalr	540(ra) # 800016f2 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800024de:	70a2                	ld	ra,40(sp)
    800024e0:	7402                	ld	s0,32(sp)
    800024e2:	64e2                	ld	s1,24(sp)
    800024e4:	6942                	ld	s2,16(sp)
    800024e6:	69a2                	ld	s3,8(sp)
    800024e8:	6a02                	ld	s4,0(sp)
    800024ea:	6145                	addi	sp,sp,48
    800024ec:	8082                	ret
    memmove(dst, (char*)src, len);
    800024ee:	000a061b          	sext.w	a2,s4
    800024f2:	85ce                	mv	a1,s3
    800024f4:	854a                	mv	a0,s2
    800024f6:	fffff097          	auipc	ra,0xfffff
    800024fa:	834080e7          	jalr	-1996(ra) # 80000d2a <memmove>
    return 0;
    800024fe:	8526                	mv	a0,s1
    80002500:	bff9                	j	800024de <either_copyin+0x32>

0000000080002502 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002502:	715d                	addi	sp,sp,-80
    80002504:	e486                	sd	ra,72(sp)
    80002506:	e0a2                	sd	s0,64(sp)
    80002508:	fc26                	sd	s1,56(sp)
    8000250a:	f84a                	sd	s2,48(sp)
    8000250c:	f44e                	sd	s3,40(sp)
    8000250e:	f052                	sd	s4,32(sp)
    80002510:	ec56                	sd	s5,24(sp)
    80002512:	e85a                	sd	s6,16(sp)
    80002514:	e45e                	sd	s7,8(sp)
    80002516:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002518:	00006517          	auipc	a0,0x6
    8000251c:	bb050513          	addi	a0,a0,-1104 # 800080c8 <digits+0x88>
    80002520:	ffffe097          	auipc	ra,0xffffe
    80002524:	066080e7          	jalr	102(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002528:	0000f497          	auipc	s1,0xf
    8000252c:	b9048493          	addi	s1,s1,-1136 # 800110b8 <proc+0x158>
    80002530:	00014917          	auipc	s2,0x14
    80002534:	58890913          	addi	s2,s2,1416 # 80016ab8 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002538:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000253a:	00006997          	auipc	s3,0x6
    8000253e:	d4698993          	addi	s3,s3,-698 # 80008280 <digits+0x240>
    printf("%d %s %s", p->pid, state, p->name);
    80002542:	00006a97          	auipc	s5,0x6
    80002546:	d46a8a93          	addi	s5,s5,-698 # 80008288 <digits+0x248>
    printf("\n");
    8000254a:	00006a17          	auipc	s4,0x6
    8000254e:	b7ea0a13          	addi	s4,s4,-1154 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002552:	00006b97          	auipc	s7,0x6
    80002556:	d76b8b93          	addi	s7,s7,-650 # 800082c8 <states.0>
    8000255a:	a00d                	j	8000257c <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    8000255c:	ed86a583          	lw	a1,-296(a3)
    80002560:	8556                	mv	a0,s5
    80002562:	ffffe097          	auipc	ra,0xffffe
    80002566:	024080e7          	jalr	36(ra) # 80000586 <printf>
    printf("\n");
    8000256a:	8552                	mv	a0,s4
    8000256c:	ffffe097          	auipc	ra,0xffffe
    80002570:	01a080e7          	jalr	26(ra) # 80000586 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002574:	16848493          	addi	s1,s1,360
    80002578:	03248263          	beq	s1,s2,8000259c <procdump+0x9a>
    if(p->state == UNUSED)
    8000257c:	86a6                	mv	a3,s1
    8000257e:	ec04a783          	lw	a5,-320(s1)
    80002582:	dbed                	beqz	a5,80002574 <procdump+0x72>
      state = "???";
    80002584:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002586:	fcfb6be3          	bltu	s6,a5,8000255c <procdump+0x5a>
    8000258a:	02079713          	slli	a4,a5,0x20
    8000258e:	01d75793          	srli	a5,a4,0x1d
    80002592:	97de                	add	a5,a5,s7
    80002594:	6390                	ld	a2,0(a5)
    80002596:	f279                	bnez	a2,8000255c <procdump+0x5a>
      state = "???";
    80002598:	864e                	mv	a2,s3
    8000259a:	b7c9                	j	8000255c <procdump+0x5a>
  }
}
    8000259c:	60a6                	ld	ra,72(sp)
    8000259e:	6406                	ld	s0,64(sp)
    800025a0:	74e2                	ld	s1,56(sp)
    800025a2:	7942                	ld	s2,48(sp)
    800025a4:	79a2                	ld	s3,40(sp)
    800025a6:	7a02                	ld	s4,32(sp)
    800025a8:	6ae2                	ld	s5,24(sp)
    800025aa:	6b42                	ld	s6,16(sp)
    800025ac:	6ba2                	ld	s7,8(sp)
    800025ae:	6161                	addi	sp,sp,80
    800025b0:	8082                	ret

00000000800025b2 <swtch>:
    800025b2:	00153023          	sd	ra,0(a0)
    800025b6:	00253423          	sd	sp,8(a0)
    800025ba:	e900                	sd	s0,16(a0)
    800025bc:	ed04                	sd	s1,24(a0)
    800025be:	03253023          	sd	s2,32(a0)
    800025c2:	03353423          	sd	s3,40(a0)
    800025c6:	03453823          	sd	s4,48(a0)
    800025ca:	03553c23          	sd	s5,56(a0)
    800025ce:	05653023          	sd	s6,64(a0)
    800025d2:	05753423          	sd	s7,72(a0)
    800025d6:	05853823          	sd	s8,80(a0)
    800025da:	05953c23          	sd	s9,88(a0)
    800025de:	07a53023          	sd	s10,96(a0)
    800025e2:	07b53423          	sd	s11,104(a0)
    800025e6:	0005b083          	ld	ra,0(a1)
    800025ea:	0085b103          	ld	sp,8(a1)
    800025ee:	6980                	ld	s0,16(a1)
    800025f0:	6d84                	ld	s1,24(a1)
    800025f2:	0205b903          	ld	s2,32(a1)
    800025f6:	0285b983          	ld	s3,40(a1)
    800025fa:	0305ba03          	ld	s4,48(a1)
    800025fe:	0385ba83          	ld	s5,56(a1)
    80002602:	0405bb03          	ld	s6,64(a1)
    80002606:	0485bb83          	ld	s7,72(a1)
    8000260a:	0505bc03          	ld	s8,80(a1)
    8000260e:	0585bc83          	ld	s9,88(a1)
    80002612:	0605bd03          	ld	s10,96(a1)
    80002616:	0685bd83          	ld	s11,104(a1)
    8000261a:	8082                	ret

000000008000261c <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000261c:	1141                	addi	sp,sp,-16
    8000261e:	e406                	sd	ra,8(sp)
    80002620:	e022                	sd	s0,0(sp)
    80002622:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002624:	00006597          	auipc	a1,0x6
    80002628:	cd458593          	addi	a1,a1,-812 # 800082f8 <states.0+0x30>
    8000262c:	00014517          	auipc	a0,0x14
    80002630:	33450513          	addi	a0,a0,820 # 80016960 <tickslock>
    80002634:	ffffe097          	auipc	ra,0xffffe
    80002638:	50e080e7          	jalr	1294(ra) # 80000b42 <initlock>
}
    8000263c:	60a2                	ld	ra,8(sp)
    8000263e:	6402                	ld	s0,0(sp)
    80002640:	0141                	addi	sp,sp,16
    80002642:	8082                	ret

0000000080002644 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002644:	1141                	addi	sp,sp,-16
    80002646:	e422                	sd	s0,8(sp)
    80002648:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000264a:	00003797          	auipc	a5,0x3
    8000264e:	46678793          	addi	a5,a5,1126 # 80005ab0 <kernelvec>
    80002652:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002656:	6422                	ld	s0,8(sp)
    80002658:	0141                	addi	sp,sp,16
    8000265a:	8082                	ret

000000008000265c <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    8000265c:	1141                	addi	sp,sp,-16
    8000265e:	e406                	sd	ra,8(sp)
    80002660:	e022                	sd	s0,0(sp)
    80002662:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80002664:	fffff097          	auipc	ra,0xfffff
    80002668:	342080e7          	jalr	834(ra) # 800019a6 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000266c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002670:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002672:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    80002676:	00005697          	auipc	a3,0x5
    8000267a:	98a68693          	addi	a3,a3,-1654 # 80007000 <_trampoline>
    8000267e:	00005717          	auipc	a4,0x5
    80002682:	98270713          	addi	a4,a4,-1662 # 80007000 <_trampoline>
    80002686:	8f15                	sub	a4,a4,a3
    80002688:	040007b7          	lui	a5,0x4000
    8000268c:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    8000268e:	07b2                	slli	a5,a5,0xc
    80002690:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002692:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80002696:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80002698:	18002673          	csrr	a2,satp
    8000269c:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    8000269e:	6d30                	ld	a2,88(a0)
    800026a0:	6138                	ld	a4,64(a0)
    800026a2:	6585                	lui	a1,0x1
    800026a4:	972e                	add	a4,a4,a1
    800026a6:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800026a8:	6d38                	ld	a4,88(a0)
    800026aa:	00000617          	auipc	a2,0x0
    800026ae:	13460613          	addi	a2,a2,308 # 800027de <usertrap>
    800026b2:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800026b4:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800026b6:	8612                	mv	a2,tp
    800026b8:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026ba:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800026be:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800026c2:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026c6:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800026ca:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026cc:	6f18                	ld	a4,24(a4)
    800026ce:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800026d2:	6928                	ld	a0,80(a0)
    800026d4:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800026d6:	00005717          	auipc	a4,0x5
    800026da:	9c670713          	addi	a4,a4,-1594 # 8000709c <userret>
    800026de:	8f15                	sub	a4,a4,a3
    800026e0:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800026e2:	577d                	li	a4,-1
    800026e4:	177e                	slli	a4,a4,0x3f
    800026e6:	8d59                	or	a0,a0,a4
    800026e8:	9782                	jalr	a5
}
    800026ea:	60a2                	ld	ra,8(sp)
    800026ec:	6402                	ld	s0,0(sp)
    800026ee:	0141                	addi	sp,sp,16
    800026f0:	8082                	ret

00000000800026f2 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800026f2:	1101                	addi	sp,sp,-32
    800026f4:	ec06                	sd	ra,24(sp)
    800026f6:	e822                	sd	s0,16(sp)
    800026f8:	e426                	sd	s1,8(sp)
    800026fa:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    800026fc:	00014497          	auipc	s1,0x14
    80002700:	26448493          	addi	s1,s1,612 # 80016960 <tickslock>
    80002704:	8526                	mv	a0,s1
    80002706:	ffffe097          	auipc	ra,0xffffe
    8000270a:	4cc080e7          	jalr	1228(ra) # 80000bd2 <acquire>
  ticks++;
    8000270e:	00006517          	auipc	a0,0x6
    80002712:	1b250513          	addi	a0,a0,434 # 800088c0 <ticks>
    80002716:	411c                	lw	a5,0(a0)
    80002718:	2785                	addiw	a5,a5,1
    8000271a:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    8000271c:	00000097          	auipc	ra,0x0
    80002720:	996080e7          	jalr	-1642(ra) # 800020b2 <wakeup>
  release(&tickslock);
    80002724:	8526                	mv	a0,s1
    80002726:	ffffe097          	auipc	ra,0xffffe
    8000272a:	560080e7          	jalr	1376(ra) # 80000c86 <release>
}
    8000272e:	60e2                	ld	ra,24(sp)
    80002730:	6442                	ld	s0,16(sp)
    80002732:	64a2                	ld	s1,8(sp)
    80002734:	6105                	addi	sp,sp,32
    80002736:	8082                	ret

0000000080002738 <devintr>:
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002738:	142027f3          	csrr	a5,scause
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    8000273c:	4501                	li	a0,0
  if((scause & 0x8000000000000000L) &&
    8000273e:	0807df63          	bgez	a5,800027dc <devintr+0xa4>
{
    80002742:	1101                	addi	sp,sp,-32
    80002744:	ec06                	sd	ra,24(sp)
    80002746:	e822                	sd	s0,16(sp)
    80002748:	e426                	sd	s1,8(sp)
    8000274a:	1000                	addi	s0,sp,32
     (scause & 0xff) == 9){
    8000274c:	0ff7f713          	zext.b	a4,a5
  if((scause & 0x8000000000000000L) &&
    80002750:	46a5                	li	a3,9
    80002752:	00d70d63          	beq	a4,a3,8000276c <devintr+0x34>
  } else if(scause == 0x8000000000000001L){
    80002756:	577d                	li	a4,-1
    80002758:	177e                	slli	a4,a4,0x3f
    8000275a:	0705                	addi	a4,a4,1
    return 0;
    8000275c:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    8000275e:	04e78e63          	beq	a5,a4,800027ba <devintr+0x82>
  }
}
    80002762:	60e2                	ld	ra,24(sp)
    80002764:	6442                	ld	s0,16(sp)
    80002766:	64a2                	ld	s1,8(sp)
    80002768:	6105                	addi	sp,sp,32
    8000276a:	8082                	ret
    int irq = plic_claim();
    8000276c:	00003097          	auipc	ra,0x3
    80002770:	44c080e7          	jalr	1100(ra) # 80005bb8 <plic_claim>
    80002774:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80002776:	47a9                	li	a5,10
    80002778:	02f50763          	beq	a0,a5,800027a6 <devintr+0x6e>
    } else if(irq == VIRTIO0_IRQ){
    8000277c:	4785                	li	a5,1
    8000277e:	02f50963          	beq	a0,a5,800027b0 <devintr+0x78>
    return 1;
    80002782:	4505                	li	a0,1
    } else if(irq){
    80002784:	dcf9                	beqz	s1,80002762 <devintr+0x2a>
      printf("unexpected interrupt irq=%d\n", irq);
    80002786:	85a6                	mv	a1,s1
    80002788:	00006517          	auipc	a0,0x6
    8000278c:	b7850513          	addi	a0,a0,-1160 # 80008300 <states.0+0x38>
    80002790:	ffffe097          	auipc	ra,0xffffe
    80002794:	df6080e7          	jalr	-522(ra) # 80000586 <printf>
      plic_complete(irq);
    80002798:	8526                	mv	a0,s1
    8000279a:	00003097          	auipc	ra,0x3
    8000279e:	442080e7          	jalr	1090(ra) # 80005bdc <plic_complete>
    return 1;
    800027a2:	4505                	li	a0,1
    800027a4:	bf7d                	j	80002762 <devintr+0x2a>
      uartintr();
    800027a6:	ffffe097          	auipc	ra,0xffffe
    800027aa:	1ee080e7          	jalr	494(ra) # 80000994 <uartintr>
    if(irq)
    800027ae:	b7ed                	j	80002798 <devintr+0x60>
      virtio_disk_intr();
    800027b0:	00004097          	auipc	ra,0x4
    800027b4:	8f2080e7          	jalr	-1806(ra) # 800060a2 <virtio_disk_intr>
    if(irq)
    800027b8:	b7c5                	j	80002798 <devintr+0x60>
    if(cpuid() == 0){
    800027ba:	fffff097          	auipc	ra,0xfffff
    800027be:	1c0080e7          	jalr	448(ra) # 8000197a <cpuid>
    800027c2:	c901                	beqz	a0,800027d2 <devintr+0x9a>
  asm volatile("csrr %0, sip" : "=r" (x) );
    800027c4:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    800027c8:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    800027ca:	14479073          	csrw	sip,a5
    return 2;
    800027ce:	4509                	li	a0,2
    800027d0:	bf49                	j	80002762 <devintr+0x2a>
      clockintr();
    800027d2:	00000097          	auipc	ra,0x0
    800027d6:	f20080e7          	jalr	-224(ra) # 800026f2 <clockintr>
    800027da:	b7ed                	j	800027c4 <devintr+0x8c>
}
    800027dc:	8082                	ret

00000000800027de <usertrap>:
{
    800027de:	1101                	addi	sp,sp,-32
    800027e0:	ec06                	sd	ra,24(sp)
    800027e2:	e822                	sd	s0,16(sp)
    800027e4:	e426                	sd	s1,8(sp)
    800027e6:	e04a                	sd	s2,0(sp)
    800027e8:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027ea:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800027ee:	1007f793          	andi	a5,a5,256
    800027f2:	e3b1                	bnez	a5,80002836 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027f4:	00003797          	auipc	a5,0x3
    800027f8:	2bc78793          	addi	a5,a5,700 # 80005ab0 <kernelvec>
    800027fc:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002800:	fffff097          	auipc	ra,0xfffff
    80002804:	1a6080e7          	jalr	422(ra) # 800019a6 <myproc>
    80002808:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000280a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000280c:	14102773          	csrr	a4,sepc
    80002810:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002812:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002816:	47a1                	li	a5,8
    80002818:	02f70763          	beq	a4,a5,80002846 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000281c:	00000097          	auipc	ra,0x0
    80002820:	f1c080e7          	jalr	-228(ra) # 80002738 <devintr>
    80002824:	892a                	mv	s2,a0
    80002826:	c151                	beqz	a0,800028aa <usertrap+0xcc>
  if(killed(p))
    80002828:	8526                	mv	a0,s1
    8000282a:	00000097          	auipc	ra,0x0
    8000282e:	acc080e7          	jalr	-1332(ra) # 800022f6 <killed>
    80002832:	c929                	beqz	a0,80002884 <usertrap+0xa6>
    80002834:	a099                	j	8000287a <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002836:	00006517          	auipc	a0,0x6
    8000283a:	aea50513          	addi	a0,a0,-1302 # 80008320 <states.0+0x58>
    8000283e:	ffffe097          	auipc	ra,0xffffe
    80002842:	cfe080e7          	jalr	-770(ra) # 8000053c <panic>
    if(killed(p))
    80002846:	00000097          	auipc	ra,0x0
    8000284a:	ab0080e7          	jalr	-1360(ra) # 800022f6 <killed>
    8000284e:	e921                	bnez	a0,8000289e <usertrap+0xc0>
    p->trapframe->epc += 4;
    80002850:	6cb8                	ld	a4,88(s1)
    80002852:	6f1c                	ld	a5,24(a4)
    80002854:	0791                	addi	a5,a5,4
    80002856:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002858:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000285c:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002860:	10079073          	csrw	sstatus,a5
    syscall();
    80002864:	00000097          	auipc	ra,0x0
    80002868:	2d4080e7          	jalr	724(ra) # 80002b38 <syscall>
  if(killed(p))
    8000286c:	8526                	mv	a0,s1
    8000286e:	00000097          	auipc	ra,0x0
    80002872:	a88080e7          	jalr	-1400(ra) # 800022f6 <killed>
    80002876:	c911                	beqz	a0,8000288a <usertrap+0xac>
    80002878:	4901                	li	s2,0
    exit(-1);
    8000287a:	557d                	li	a0,-1
    8000287c:	00000097          	auipc	ra,0x0
    80002880:	906080e7          	jalr	-1786(ra) # 80002182 <exit>
  if(which_dev == 2)
    80002884:	4789                	li	a5,2
    80002886:	04f90f63          	beq	s2,a5,800028e4 <usertrap+0x106>
  usertrapret();
    8000288a:	00000097          	auipc	ra,0x0
    8000288e:	dd2080e7          	jalr	-558(ra) # 8000265c <usertrapret>
}
    80002892:	60e2                	ld	ra,24(sp)
    80002894:	6442                	ld	s0,16(sp)
    80002896:	64a2                	ld	s1,8(sp)
    80002898:	6902                	ld	s2,0(sp)
    8000289a:	6105                	addi	sp,sp,32
    8000289c:	8082                	ret
      exit(-1);
    8000289e:	557d                	li	a0,-1
    800028a0:	00000097          	auipc	ra,0x0
    800028a4:	8e2080e7          	jalr	-1822(ra) # 80002182 <exit>
    800028a8:	b765                	j	80002850 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800028aa:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800028ae:	5890                	lw	a2,48(s1)
    800028b0:	00006517          	auipc	a0,0x6
    800028b4:	a9050513          	addi	a0,a0,-1392 # 80008340 <states.0+0x78>
    800028b8:	ffffe097          	auipc	ra,0xffffe
    800028bc:	cce080e7          	jalr	-818(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028c0:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800028c4:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    800028c8:	00006517          	auipc	a0,0x6
    800028cc:	aa850513          	addi	a0,a0,-1368 # 80008370 <states.0+0xa8>
    800028d0:	ffffe097          	auipc	ra,0xffffe
    800028d4:	cb6080e7          	jalr	-842(ra) # 80000586 <printf>
    setkilled(p);
    800028d8:	8526                	mv	a0,s1
    800028da:	00000097          	auipc	ra,0x0
    800028de:	9f0080e7          	jalr	-1552(ra) # 800022ca <setkilled>
    800028e2:	b769                	j	8000286c <usertrap+0x8e>
    yield();
    800028e4:	fffff097          	auipc	ra,0xfffff
    800028e8:	72e080e7          	jalr	1838(ra) # 80002012 <yield>
    800028ec:	bf79                	j	8000288a <usertrap+0xac>

00000000800028ee <kerneltrap>:
{
    800028ee:	7179                	addi	sp,sp,-48
    800028f0:	f406                	sd	ra,40(sp)
    800028f2:	f022                	sd	s0,32(sp)
    800028f4:	ec26                	sd	s1,24(sp)
    800028f6:	e84a                	sd	s2,16(sp)
    800028f8:	e44e                	sd	s3,8(sp)
    800028fa:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800028fc:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002900:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002904:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002908:	1004f793          	andi	a5,s1,256
    8000290c:	cb85                	beqz	a5,8000293c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000290e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002912:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002914:	ef85                	bnez	a5,8000294c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002916:	00000097          	auipc	ra,0x0
    8000291a:	e22080e7          	jalr	-478(ra) # 80002738 <devintr>
    8000291e:	cd1d                	beqz	a0,8000295c <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002920:	4789                	li	a5,2
    80002922:	06f50a63          	beq	a0,a5,80002996 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002926:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000292a:	10049073          	csrw	sstatus,s1
}
    8000292e:	70a2                	ld	ra,40(sp)
    80002930:	7402                	ld	s0,32(sp)
    80002932:	64e2                	ld	s1,24(sp)
    80002934:	6942                	ld	s2,16(sp)
    80002936:	69a2                	ld	s3,8(sp)
    80002938:	6145                	addi	sp,sp,48
    8000293a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    8000293c:	00006517          	auipc	a0,0x6
    80002940:	a5450513          	addi	a0,a0,-1452 # 80008390 <states.0+0xc8>
    80002944:	ffffe097          	auipc	ra,0xffffe
    80002948:	bf8080e7          	jalr	-1032(ra) # 8000053c <panic>
    panic("kerneltrap: interrupts enabled");
    8000294c:	00006517          	auipc	a0,0x6
    80002950:	a6c50513          	addi	a0,a0,-1428 # 800083b8 <states.0+0xf0>
    80002954:	ffffe097          	auipc	ra,0xffffe
    80002958:	be8080e7          	jalr	-1048(ra) # 8000053c <panic>
    printf("scause %p\n", scause);
    8000295c:	85ce                	mv	a1,s3
    8000295e:	00006517          	auipc	a0,0x6
    80002962:	a7a50513          	addi	a0,a0,-1414 # 800083d8 <states.0+0x110>
    80002966:	ffffe097          	auipc	ra,0xffffe
    8000296a:	c20080e7          	jalr	-992(ra) # 80000586 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000296e:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002972:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002976:	00006517          	auipc	a0,0x6
    8000297a:	a7250513          	addi	a0,a0,-1422 # 800083e8 <states.0+0x120>
    8000297e:	ffffe097          	auipc	ra,0xffffe
    80002982:	c08080e7          	jalr	-1016(ra) # 80000586 <printf>
    panic("kerneltrap");
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	a7a50513          	addi	a0,a0,-1414 # 80008400 <states.0+0x138>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	bae080e7          	jalr	-1106(ra) # 8000053c <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002996:	fffff097          	auipc	ra,0xfffff
    8000299a:	010080e7          	jalr	16(ra) # 800019a6 <myproc>
    8000299e:	d541                	beqz	a0,80002926 <kerneltrap+0x38>
    800029a0:	fffff097          	auipc	ra,0xfffff
    800029a4:	006080e7          	jalr	6(ra) # 800019a6 <myproc>
    800029a8:	4d18                	lw	a4,24(a0)
    800029aa:	4791                	li	a5,4
    800029ac:	f6f71de3          	bne	a4,a5,80002926 <kerneltrap+0x38>
    yield();
    800029b0:	fffff097          	auipc	ra,0xfffff
    800029b4:	662080e7          	jalr	1634(ra) # 80002012 <yield>
    800029b8:	b7bd                	j	80002926 <kerneltrap+0x38>

00000000800029ba <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    800029ba:	1101                	addi	sp,sp,-32
    800029bc:	ec06                	sd	ra,24(sp)
    800029be:	e822                	sd	s0,16(sp)
    800029c0:	e426                	sd	s1,8(sp)
    800029c2:	1000                	addi	s0,sp,32
    800029c4:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    800029c6:	fffff097          	auipc	ra,0xfffff
    800029ca:	fe0080e7          	jalr	-32(ra) # 800019a6 <myproc>
  switch (n) {
    800029ce:	4795                	li	a5,5
    800029d0:	0497e163          	bltu	a5,s1,80002a12 <argraw+0x58>
    800029d4:	048a                	slli	s1,s1,0x2
    800029d6:	00006717          	auipc	a4,0x6
    800029da:	a6270713          	addi	a4,a4,-1438 # 80008438 <states.0+0x170>
    800029de:	94ba                	add	s1,s1,a4
    800029e0:	409c                	lw	a5,0(s1)
    800029e2:	97ba                	add	a5,a5,a4
    800029e4:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    800029e6:	6d3c                	ld	a5,88(a0)
    800029e8:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    800029ea:	60e2                	ld	ra,24(sp)
    800029ec:	6442                	ld	s0,16(sp)
    800029ee:	64a2                	ld	s1,8(sp)
    800029f0:	6105                	addi	sp,sp,32
    800029f2:	8082                	ret
    return p->trapframe->a1;
    800029f4:	6d3c                	ld	a5,88(a0)
    800029f6:	7fa8                	ld	a0,120(a5)
    800029f8:	bfcd                	j	800029ea <argraw+0x30>
    return p->trapframe->a2;
    800029fa:	6d3c                	ld	a5,88(a0)
    800029fc:	63c8                	ld	a0,128(a5)
    800029fe:	b7f5                	j	800029ea <argraw+0x30>
    return p->trapframe->a3;
    80002a00:	6d3c                	ld	a5,88(a0)
    80002a02:	67c8                	ld	a0,136(a5)
    80002a04:	b7dd                	j	800029ea <argraw+0x30>
    return p->trapframe->a4;
    80002a06:	6d3c                	ld	a5,88(a0)
    80002a08:	6bc8                	ld	a0,144(a5)
    80002a0a:	b7c5                	j	800029ea <argraw+0x30>
    return p->trapframe->a5;
    80002a0c:	6d3c                	ld	a5,88(a0)
    80002a0e:	6fc8                	ld	a0,152(a5)
    80002a10:	bfe9                	j	800029ea <argraw+0x30>
  panic("argraw");
    80002a12:	00006517          	auipc	a0,0x6
    80002a16:	9fe50513          	addi	a0,a0,-1538 # 80008410 <states.0+0x148>
    80002a1a:	ffffe097          	auipc	ra,0xffffe
    80002a1e:	b22080e7          	jalr	-1246(ra) # 8000053c <panic>

0000000080002a22 <fetchaddr>:
{
    80002a22:	1101                	addi	sp,sp,-32
    80002a24:	ec06                	sd	ra,24(sp)
    80002a26:	e822                	sd	s0,16(sp)
    80002a28:	e426                	sd	s1,8(sp)
    80002a2a:	e04a                	sd	s2,0(sp)
    80002a2c:	1000                	addi	s0,sp,32
    80002a2e:	84aa                	mv	s1,a0
    80002a30:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002a32:	fffff097          	auipc	ra,0xfffff
    80002a36:	f74080e7          	jalr	-140(ra) # 800019a6 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002a3a:	653c                	ld	a5,72(a0)
    80002a3c:	02f4f863          	bgeu	s1,a5,80002a6c <fetchaddr+0x4a>
    80002a40:	00848713          	addi	a4,s1,8
    80002a44:	02e7e663          	bltu	a5,a4,80002a70 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002a48:	46a1                	li	a3,8
    80002a4a:	8626                	mv	a2,s1
    80002a4c:	85ca                	mv	a1,s2
    80002a4e:	6928                	ld	a0,80(a0)
    80002a50:	fffff097          	auipc	ra,0xfffff
    80002a54:	ca2080e7          	jalr	-862(ra) # 800016f2 <copyin>
    80002a58:	00a03533          	snez	a0,a0
    80002a5c:	40a00533          	neg	a0,a0
}
    80002a60:	60e2                	ld	ra,24(sp)
    80002a62:	6442                	ld	s0,16(sp)
    80002a64:	64a2                	ld	s1,8(sp)
    80002a66:	6902                	ld	s2,0(sp)
    80002a68:	6105                	addi	sp,sp,32
    80002a6a:	8082                	ret
    return -1;
    80002a6c:	557d                	li	a0,-1
    80002a6e:	bfcd                	j	80002a60 <fetchaddr+0x3e>
    80002a70:	557d                	li	a0,-1
    80002a72:	b7fd                	j	80002a60 <fetchaddr+0x3e>

0000000080002a74 <fetchstr>:
{
    80002a74:	7179                	addi	sp,sp,-48
    80002a76:	f406                	sd	ra,40(sp)
    80002a78:	f022                	sd	s0,32(sp)
    80002a7a:	ec26                	sd	s1,24(sp)
    80002a7c:	e84a                	sd	s2,16(sp)
    80002a7e:	e44e                	sd	s3,8(sp)
    80002a80:	1800                	addi	s0,sp,48
    80002a82:	892a                	mv	s2,a0
    80002a84:	84ae                	mv	s1,a1
    80002a86:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002a88:	fffff097          	auipc	ra,0xfffff
    80002a8c:	f1e080e7          	jalr	-226(ra) # 800019a6 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002a90:	86ce                	mv	a3,s3
    80002a92:	864a                	mv	a2,s2
    80002a94:	85a6                	mv	a1,s1
    80002a96:	6928                	ld	a0,80(a0)
    80002a98:	fffff097          	auipc	ra,0xfffff
    80002a9c:	ce8080e7          	jalr	-792(ra) # 80001780 <copyinstr>
    80002aa0:	00054e63          	bltz	a0,80002abc <fetchstr+0x48>
  return strlen(buf);
    80002aa4:	8526                	mv	a0,s1
    80002aa6:	ffffe097          	auipc	ra,0xffffe
    80002aaa:	3a2080e7          	jalr	930(ra) # 80000e48 <strlen>
}
    80002aae:	70a2                	ld	ra,40(sp)
    80002ab0:	7402                	ld	s0,32(sp)
    80002ab2:	64e2                	ld	s1,24(sp)
    80002ab4:	6942                	ld	s2,16(sp)
    80002ab6:	69a2                	ld	s3,8(sp)
    80002ab8:	6145                	addi	sp,sp,48
    80002aba:	8082                	ret
    return -1;
    80002abc:	557d                	li	a0,-1
    80002abe:	bfc5                	j	80002aae <fetchstr+0x3a>

0000000080002ac0 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002ac0:	1101                	addi	sp,sp,-32
    80002ac2:	ec06                	sd	ra,24(sp)
    80002ac4:	e822                	sd	s0,16(sp)
    80002ac6:	e426                	sd	s1,8(sp)
    80002ac8:	1000                	addi	s0,sp,32
    80002aca:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002acc:	00000097          	auipc	ra,0x0
    80002ad0:	eee080e7          	jalr	-274(ra) # 800029ba <argraw>
    80002ad4:	c088                	sw	a0,0(s1)
}
    80002ad6:	60e2                	ld	ra,24(sp)
    80002ad8:	6442                	ld	s0,16(sp)
    80002ada:	64a2                	ld	s1,8(sp)
    80002adc:	6105                	addi	sp,sp,32
    80002ade:	8082                	ret

0000000080002ae0 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002ae0:	1101                	addi	sp,sp,-32
    80002ae2:	ec06                	sd	ra,24(sp)
    80002ae4:	e822                	sd	s0,16(sp)
    80002ae6:	e426                	sd	s1,8(sp)
    80002ae8:	1000                	addi	s0,sp,32
    80002aea:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002aec:	00000097          	auipc	ra,0x0
    80002af0:	ece080e7          	jalr	-306(ra) # 800029ba <argraw>
    80002af4:	e088                	sd	a0,0(s1)
}
    80002af6:	60e2                	ld	ra,24(sp)
    80002af8:	6442                	ld	s0,16(sp)
    80002afa:	64a2                	ld	s1,8(sp)
    80002afc:	6105                	addi	sp,sp,32
    80002afe:	8082                	ret

0000000080002b00 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002b00:	7179                	addi	sp,sp,-48
    80002b02:	f406                	sd	ra,40(sp)
    80002b04:	f022                	sd	s0,32(sp)
    80002b06:	ec26                	sd	s1,24(sp)
    80002b08:	e84a                	sd	s2,16(sp)
    80002b0a:	1800                	addi	s0,sp,48
    80002b0c:	84ae                	mv	s1,a1
    80002b0e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002b10:	fd840593          	addi	a1,s0,-40
    80002b14:	00000097          	auipc	ra,0x0
    80002b18:	fcc080e7          	jalr	-52(ra) # 80002ae0 <argaddr>
  return fetchstr(addr, buf, max);
    80002b1c:	864a                	mv	a2,s2
    80002b1e:	85a6                	mv	a1,s1
    80002b20:	fd843503          	ld	a0,-40(s0)
    80002b24:	00000097          	auipc	ra,0x0
    80002b28:	f50080e7          	jalr	-176(ra) # 80002a74 <fetchstr>
}
    80002b2c:	70a2                	ld	ra,40(sp)
    80002b2e:	7402                	ld	s0,32(sp)
    80002b30:	64e2                	ld	s1,24(sp)
    80002b32:	6942                	ld	s2,16(sp)
    80002b34:	6145                	addi	sp,sp,48
    80002b36:	8082                	ret

0000000080002b38 <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    80002b38:	1101                	addi	sp,sp,-32
    80002b3a:	ec06                	sd	ra,24(sp)
    80002b3c:	e822                	sd	s0,16(sp)
    80002b3e:	e426                	sd	s1,8(sp)
    80002b40:	e04a                	sd	s2,0(sp)
    80002b42:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002b44:	fffff097          	auipc	ra,0xfffff
    80002b48:	e62080e7          	jalr	-414(ra) # 800019a6 <myproc>
    80002b4c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002b4e:	05853903          	ld	s2,88(a0)
    80002b52:	0a893783          	ld	a5,168(s2)
    80002b56:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002b5a:	37fd                	addiw	a5,a5,-1
    80002b5c:	4751                	li	a4,20
    80002b5e:	00f76f63          	bltu	a4,a5,80002b7c <syscall+0x44>
    80002b62:	00369713          	slli	a4,a3,0x3
    80002b66:	00006797          	auipc	a5,0x6
    80002b6a:	8ea78793          	addi	a5,a5,-1814 # 80008450 <syscalls>
    80002b6e:	97ba                	add	a5,a5,a4
    80002b70:	639c                	ld	a5,0(a5)
    80002b72:	c789                	beqz	a5,80002b7c <syscall+0x44>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002b74:	9782                	jalr	a5
    80002b76:	06a93823          	sd	a0,112(s2)
    80002b7a:	a839                	j	80002b98 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002b7c:	15848613          	addi	a2,s1,344
    80002b80:	588c                	lw	a1,48(s1)
    80002b82:	00006517          	auipc	a0,0x6
    80002b86:	89650513          	addi	a0,a0,-1898 # 80008418 <states.0+0x150>
    80002b8a:	ffffe097          	auipc	ra,0xffffe
    80002b8e:	9fc080e7          	jalr	-1540(ra) # 80000586 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002b92:	6cbc                	ld	a5,88(s1)
    80002b94:	577d                	li	a4,-1
    80002b96:	fbb8                	sd	a4,112(a5)
  }
}
    80002b98:	60e2                	ld	ra,24(sp)
    80002b9a:	6442                	ld	s0,16(sp)
    80002b9c:	64a2                	ld	s1,8(sp)
    80002b9e:	6902                	ld	s2,0(sp)
    80002ba0:	6105                	addi	sp,sp,32
    80002ba2:	8082                	ret

0000000080002ba4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002ba4:	1101                	addi	sp,sp,-32
    80002ba6:	ec06                	sd	ra,24(sp)
    80002ba8:	e822                	sd	s0,16(sp)
    80002baa:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002bac:	fec40593          	addi	a1,s0,-20
    80002bb0:	4501                	li	a0,0
    80002bb2:	00000097          	auipc	ra,0x0
    80002bb6:	f0e080e7          	jalr	-242(ra) # 80002ac0 <argint>
  exit(n);
    80002bba:	fec42503          	lw	a0,-20(s0)
    80002bbe:	fffff097          	auipc	ra,0xfffff
    80002bc2:	5c4080e7          	jalr	1476(ra) # 80002182 <exit>
  return 0;  // not reached
}
    80002bc6:	4501                	li	a0,0
    80002bc8:	60e2                	ld	ra,24(sp)
    80002bca:	6442                	ld	s0,16(sp)
    80002bcc:	6105                	addi	sp,sp,32
    80002bce:	8082                	ret

0000000080002bd0 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002bd0:	1141                	addi	sp,sp,-16
    80002bd2:	e406                	sd	ra,8(sp)
    80002bd4:	e022                	sd	s0,0(sp)
    80002bd6:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	dce080e7          	jalr	-562(ra) # 800019a6 <myproc>
}
    80002be0:	5908                	lw	a0,48(a0)
    80002be2:	60a2                	ld	ra,8(sp)
    80002be4:	6402                	ld	s0,0(sp)
    80002be6:	0141                	addi	sp,sp,16
    80002be8:	8082                	ret

0000000080002bea <sys_fork>:

uint64
sys_fork(void)
{
    80002bea:	1141                	addi	sp,sp,-16
    80002bec:	e406                	sd	ra,8(sp)
    80002bee:	e022                	sd	s0,0(sp)
    80002bf0:	0800                	addi	s0,sp,16
  return fork();
    80002bf2:	fffff097          	auipc	ra,0xfffff
    80002bf6:	16a080e7          	jalr	362(ra) # 80001d5c <fork>
}
    80002bfa:	60a2                	ld	ra,8(sp)
    80002bfc:	6402                	ld	s0,0(sp)
    80002bfe:	0141                	addi	sp,sp,16
    80002c00:	8082                	ret

0000000080002c02 <sys_wait>:

uint64
sys_wait(void)
{
    80002c02:	1101                	addi	sp,sp,-32
    80002c04:	ec06                	sd	ra,24(sp)
    80002c06:	e822                	sd	s0,16(sp)
    80002c08:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002c0a:	fe840593          	addi	a1,s0,-24
    80002c0e:	4501                	li	a0,0
    80002c10:	00000097          	auipc	ra,0x0
    80002c14:	ed0080e7          	jalr	-304(ra) # 80002ae0 <argaddr>
  return wait(p);
    80002c18:	fe843503          	ld	a0,-24(s0)
    80002c1c:	fffff097          	auipc	ra,0xfffff
    80002c20:	70c080e7          	jalr	1804(ra) # 80002328 <wait>
}
    80002c24:	60e2                	ld	ra,24(sp)
    80002c26:	6442                	ld	s0,16(sp)
    80002c28:	6105                	addi	sp,sp,32
    80002c2a:	8082                	ret

0000000080002c2c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002c2c:	7179                	addi	sp,sp,-48
    80002c2e:	f406                	sd	ra,40(sp)
    80002c30:	f022                	sd	s0,32(sp)
    80002c32:	ec26                	sd	s1,24(sp)
    80002c34:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002c36:	fdc40593          	addi	a1,s0,-36
    80002c3a:	4501                	li	a0,0
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	e84080e7          	jalr	-380(ra) # 80002ac0 <argint>
  addr = myproc()->sz;
    80002c44:	fffff097          	auipc	ra,0xfffff
    80002c48:	d62080e7          	jalr	-670(ra) # 800019a6 <myproc>
    80002c4c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002c4e:	fdc42503          	lw	a0,-36(s0)
    80002c52:	fffff097          	auipc	ra,0xfffff
    80002c56:	0ae080e7          	jalr	174(ra) # 80001d00 <growproc>
    80002c5a:	00054863          	bltz	a0,80002c6a <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002c5e:	8526                	mv	a0,s1
    80002c60:	70a2                	ld	ra,40(sp)
    80002c62:	7402                	ld	s0,32(sp)
    80002c64:	64e2                	ld	s1,24(sp)
    80002c66:	6145                	addi	sp,sp,48
    80002c68:	8082                	ret
    return -1;
    80002c6a:	54fd                	li	s1,-1
    80002c6c:	bfcd                	j	80002c5e <sys_sbrk+0x32>

0000000080002c6e <sys_sleep>:

uint64
sys_sleep(void)
{
    80002c6e:	7139                	addi	sp,sp,-64
    80002c70:	fc06                	sd	ra,56(sp)
    80002c72:	f822                	sd	s0,48(sp)
    80002c74:	f426                	sd	s1,40(sp)
    80002c76:	f04a                	sd	s2,32(sp)
    80002c78:	ec4e                	sd	s3,24(sp)
    80002c7a:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002c7c:	fcc40593          	addi	a1,s0,-52
    80002c80:	4501                	li	a0,0
    80002c82:	00000097          	auipc	ra,0x0
    80002c86:	e3e080e7          	jalr	-450(ra) # 80002ac0 <argint>
  acquire(&tickslock);
    80002c8a:	00014517          	auipc	a0,0x14
    80002c8e:	cd650513          	addi	a0,a0,-810 # 80016960 <tickslock>
    80002c92:	ffffe097          	auipc	ra,0xffffe
    80002c96:	f40080e7          	jalr	-192(ra) # 80000bd2 <acquire>
  ticks0 = ticks;
    80002c9a:	00006917          	auipc	s2,0x6
    80002c9e:	c2692903          	lw	s2,-986(s2) # 800088c0 <ticks>
  while(ticks - ticks0 < n){
    80002ca2:	fcc42783          	lw	a5,-52(s0)
    80002ca6:	cf9d                	beqz	a5,80002ce4 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002ca8:	00014997          	auipc	s3,0x14
    80002cac:	cb898993          	addi	s3,s3,-840 # 80016960 <tickslock>
    80002cb0:	00006497          	auipc	s1,0x6
    80002cb4:	c1048493          	addi	s1,s1,-1008 # 800088c0 <ticks>
    if(killed(myproc())){
    80002cb8:	fffff097          	auipc	ra,0xfffff
    80002cbc:	cee080e7          	jalr	-786(ra) # 800019a6 <myproc>
    80002cc0:	fffff097          	auipc	ra,0xfffff
    80002cc4:	636080e7          	jalr	1590(ra) # 800022f6 <killed>
    80002cc8:	ed15                	bnez	a0,80002d04 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002cca:	85ce                	mv	a1,s3
    80002ccc:	8526                	mv	a0,s1
    80002cce:	fffff097          	auipc	ra,0xfffff
    80002cd2:	380080e7          	jalr	896(ra) # 8000204e <sleep>
  while(ticks - ticks0 < n){
    80002cd6:	409c                	lw	a5,0(s1)
    80002cd8:	412787bb          	subw	a5,a5,s2
    80002cdc:	fcc42703          	lw	a4,-52(s0)
    80002ce0:	fce7ece3          	bltu	a5,a4,80002cb8 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002ce4:	00014517          	auipc	a0,0x14
    80002ce8:	c7c50513          	addi	a0,a0,-900 # 80016960 <tickslock>
    80002cec:	ffffe097          	auipc	ra,0xffffe
    80002cf0:	f9a080e7          	jalr	-102(ra) # 80000c86 <release>
  return 0;
    80002cf4:	4501                	li	a0,0
}
    80002cf6:	70e2                	ld	ra,56(sp)
    80002cf8:	7442                	ld	s0,48(sp)
    80002cfa:	74a2                	ld	s1,40(sp)
    80002cfc:	7902                	ld	s2,32(sp)
    80002cfe:	69e2                	ld	s3,24(sp)
    80002d00:	6121                	addi	sp,sp,64
    80002d02:	8082                	ret
      release(&tickslock);
    80002d04:	00014517          	auipc	a0,0x14
    80002d08:	c5c50513          	addi	a0,a0,-932 # 80016960 <tickslock>
    80002d0c:	ffffe097          	auipc	ra,0xffffe
    80002d10:	f7a080e7          	jalr	-134(ra) # 80000c86 <release>
      return -1;
    80002d14:	557d                	li	a0,-1
    80002d16:	b7c5                	j	80002cf6 <sys_sleep+0x88>

0000000080002d18 <sys_kill>:

uint64
sys_kill(void)
{
    80002d18:	1101                	addi	sp,sp,-32
    80002d1a:	ec06                	sd	ra,24(sp)
    80002d1c:	e822                	sd	s0,16(sp)
    80002d1e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002d20:	fec40593          	addi	a1,s0,-20
    80002d24:	4501                	li	a0,0
    80002d26:	00000097          	auipc	ra,0x0
    80002d2a:	d9a080e7          	jalr	-614(ra) # 80002ac0 <argint>
  return kill(pid);
    80002d2e:	fec42503          	lw	a0,-20(s0)
    80002d32:	fffff097          	auipc	ra,0xfffff
    80002d36:	526080e7          	jalr	1318(ra) # 80002258 <kill>
}
    80002d3a:	60e2                	ld	ra,24(sp)
    80002d3c:	6442                	ld	s0,16(sp)
    80002d3e:	6105                	addi	sp,sp,32
    80002d40:	8082                	ret

0000000080002d42 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002d42:	1101                	addi	sp,sp,-32
    80002d44:	ec06                	sd	ra,24(sp)
    80002d46:	e822                	sd	s0,16(sp)
    80002d48:	e426                	sd	s1,8(sp)
    80002d4a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002d4c:	00014517          	auipc	a0,0x14
    80002d50:	c1450513          	addi	a0,a0,-1004 # 80016960 <tickslock>
    80002d54:	ffffe097          	auipc	ra,0xffffe
    80002d58:	e7e080e7          	jalr	-386(ra) # 80000bd2 <acquire>
  xticks = ticks;
    80002d5c:	00006497          	auipc	s1,0x6
    80002d60:	b644a483          	lw	s1,-1180(s1) # 800088c0 <ticks>
  release(&tickslock);
    80002d64:	00014517          	auipc	a0,0x14
    80002d68:	bfc50513          	addi	a0,a0,-1028 # 80016960 <tickslock>
    80002d6c:	ffffe097          	auipc	ra,0xffffe
    80002d70:	f1a080e7          	jalr	-230(ra) # 80000c86 <release>
  return xticks;
}
    80002d74:	02049513          	slli	a0,s1,0x20
    80002d78:	9101                	srli	a0,a0,0x20
    80002d7a:	60e2                	ld	ra,24(sp)
    80002d7c:	6442                	ld	s0,16(sp)
    80002d7e:	64a2                	ld	s1,8(sp)
    80002d80:	6105                	addi	sp,sp,32
    80002d82:	8082                	ret

0000000080002d84 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002d84:	7179                	addi	sp,sp,-48
    80002d86:	f406                	sd	ra,40(sp)
    80002d88:	f022                	sd	s0,32(sp)
    80002d8a:	ec26                	sd	s1,24(sp)
    80002d8c:	e84a                	sd	s2,16(sp)
    80002d8e:	e44e                	sd	s3,8(sp)
    80002d90:	e052                	sd	s4,0(sp)
    80002d92:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002d94:	00005597          	auipc	a1,0x5
    80002d98:	76c58593          	addi	a1,a1,1900 # 80008500 <syscalls+0xb0>
    80002d9c:	00014517          	auipc	a0,0x14
    80002da0:	bdc50513          	addi	a0,a0,-1060 # 80016978 <bcache>
    80002da4:	ffffe097          	auipc	ra,0xffffe
    80002da8:	d9e080e7          	jalr	-610(ra) # 80000b42 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002dac:	0001c797          	auipc	a5,0x1c
    80002db0:	bcc78793          	addi	a5,a5,-1076 # 8001e978 <bcache+0x8000>
    80002db4:	0001c717          	auipc	a4,0x1c
    80002db8:	e2c70713          	addi	a4,a4,-468 # 8001ebe0 <bcache+0x8268>
    80002dbc:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002dc0:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dc4:	00014497          	auipc	s1,0x14
    80002dc8:	bcc48493          	addi	s1,s1,-1076 # 80016990 <bcache+0x18>
    b->next = bcache.head.next;
    80002dcc:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002dce:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002dd0:	00005a17          	auipc	s4,0x5
    80002dd4:	738a0a13          	addi	s4,s4,1848 # 80008508 <syscalls+0xb8>
    b->next = bcache.head.next;
    80002dd8:	2b893783          	ld	a5,696(s2)
    80002ddc:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002dde:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002de2:	85d2                	mv	a1,s4
    80002de4:	01048513          	addi	a0,s1,16
    80002de8:	00001097          	auipc	ra,0x1
    80002dec:	496080e7          	jalr	1174(ra) # 8000427e <initsleeplock>
    bcache.head.next->prev = b;
    80002df0:	2b893783          	ld	a5,696(s2)
    80002df4:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002df6:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002dfa:	45848493          	addi	s1,s1,1112
    80002dfe:	fd349de3          	bne	s1,s3,80002dd8 <binit+0x54>
  }
}
    80002e02:	70a2                	ld	ra,40(sp)
    80002e04:	7402                	ld	s0,32(sp)
    80002e06:	64e2                	ld	s1,24(sp)
    80002e08:	6942                	ld	s2,16(sp)
    80002e0a:	69a2                	ld	s3,8(sp)
    80002e0c:	6a02                	ld	s4,0(sp)
    80002e0e:	6145                	addi	sp,sp,48
    80002e10:	8082                	ret

0000000080002e12 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002e12:	7179                	addi	sp,sp,-48
    80002e14:	f406                	sd	ra,40(sp)
    80002e16:	f022                	sd	s0,32(sp)
    80002e18:	ec26                	sd	s1,24(sp)
    80002e1a:	e84a                	sd	s2,16(sp)
    80002e1c:	e44e                	sd	s3,8(sp)
    80002e1e:	1800                	addi	s0,sp,48
    80002e20:	892a                	mv	s2,a0
    80002e22:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002e24:	00014517          	auipc	a0,0x14
    80002e28:	b5450513          	addi	a0,a0,-1196 # 80016978 <bcache>
    80002e2c:	ffffe097          	auipc	ra,0xffffe
    80002e30:	da6080e7          	jalr	-602(ra) # 80000bd2 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002e34:	0001c497          	auipc	s1,0x1c
    80002e38:	dfc4b483          	ld	s1,-516(s1) # 8001ec30 <bcache+0x82b8>
    80002e3c:	0001c797          	auipc	a5,0x1c
    80002e40:	da478793          	addi	a5,a5,-604 # 8001ebe0 <bcache+0x8268>
    80002e44:	02f48f63          	beq	s1,a5,80002e82 <bread+0x70>
    80002e48:	873e                	mv	a4,a5
    80002e4a:	a021                	j	80002e52 <bread+0x40>
    80002e4c:	68a4                	ld	s1,80(s1)
    80002e4e:	02e48a63          	beq	s1,a4,80002e82 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80002e52:	449c                	lw	a5,8(s1)
    80002e54:	ff279ce3          	bne	a5,s2,80002e4c <bread+0x3a>
    80002e58:	44dc                	lw	a5,12(s1)
    80002e5a:	ff3799e3          	bne	a5,s3,80002e4c <bread+0x3a>
      b->refcnt++;
    80002e5e:	40bc                	lw	a5,64(s1)
    80002e60:	2785                	addiw	a5,a5,1
    80002e62:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002e64:	00014517          	auipc	a0,0x14
    80002e68:	b1450513          	addi	a0,a0,-1260 # 80016978 <bcache>
    80002e6c:	ffffe097          	auipc	ra,0xffffe
    80002e70:	e1a080e7          	jalr	-486(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002e74:	01048513          	addi	a0,s1,16
    80002e78:	00001097          	auipc	ra,0x1
    80002e7c:	440080e7          	jalr	1088(ra) # 800042b8 <acquiresleep>
      return b;
    80002e80:	a8b9                	j	80002ede <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e82:	0001c497          	auipc	s1,0x1c
    80002e86:	da64b483          	ld	s1,-602(s1) # 8001ec28 <bcache+0x82b0>
    80002e8a:	0001c797          	auipc	a5,0x1c
    80002e8e:	d5678793          	addi	a5,a5,-682 # 8001ebe0 <bcache+0x8268>
    80002e92:	00f48863          	beq	s1,a5,80002ea2 <bread+0x90>
    80002e96:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002e98:	40bc                	lw	a5,64(s1)
    80002e9a:	cf81                	beqz	a5,80002eb2 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002e9c:	64a4                	ld	s1,72(s1)
    80002e9e:	fee49de3          	bne	s1,a4,80002e98 <bread+0x86>
  panic("bget: no buffers");
    80002ea2:	00005517          	auipc	a0,0x5
    80002ea6:	66e50513          	addi	a0,a0,1646 # 80008510 <syscalls+0xc0>
    80002eaa:	ffffd097          	auipc	ra,0xffffd
    80002eae:	692080e7          	jalr	1682(ra) # 8000053c <panic>
      b->dev = dev;
    80002eb2:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002eb6:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002eba:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002ebe:	4785                	li	a5,1
    80002ec0:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002ec2:	00014517          	auipc	a0,0x14
    80002ec6:	ab650513          	addi	a0,a0,-1354 # 80016978 <bcache>
    80002eca:	ffffe097          	auipc	ra,0xffffe
    80002ece:	dbc080e7          	jalr	-580(ra) # 80000c86 <release>
      acquiresleep(&b->lock);
    80002ed2:	01048513          	addi	a0,s1,16
    80002ed6:	00001097          	auipc	ra,0x1
    80002eda:	3e2080e7          	jalr	994(ra) # 800042b8 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002ede:	409c                	lw	a5,0(s1)
    80002ee0:	cb89                	beqz	a5,80002ef2 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002ee2:	8526                	mv	a0,s1
    80002ee4:	70a2                	ld	ra,40(sp)
    80002ee6:	7402                	ld	s0,32(sp)
    80002ee8:	64e2                	ld	s1,24(sp)
    80002eea:	6942                	ld	s2,16(sp)
    80002eec:	69a2                	ld	s3,8(sp)
    80002eee:	6145                	addi	sp,sp,48
    80002ef0:	8082                	ret
    virtio_disk_rw(b, 0);
    80002ef2:	4581                	li	a1,0
    80002ef4:	8526                	mv	a0,s1
    80002ef6:	00003097          	auipc	ra,0x3
    80002efa:	f7c080e7          	jalr	-132(ra) # 80005e72 <virtio_disk_rw>
    b->valid = 1;
    80002efe:	4785                	li	a5,1
    80002f00:	c09c                	sw	a5,0(s1)
  return b;
    80002f02:	b7c5                	j	80002ee2 <bread+0xd0>

0000000080002f04 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002f04:	1101                	addi	sp,sp,-32
    80002f06:	ec06                	sd	ra,24(sp)
    80002f08:	e822                	sd	s0,16(sp)
    80002f0a:	e426                	sd	s1,8(sp)
    80002f0c:	1000                	addi	s0,sp,32
    80002f0e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f10:	0541                	addi	a0,a0,16
    80002f12:	00001097          	auipc	ra,0x1
    80002f16:	440080e7          	jalr	1088(ra) # 80004352 <holdingsleep>
    80002f1a:	cd01                	beqz	a0,80002f32 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002f1c:	4585                	li	a1,1
    80002f1e:	8526                	mv	a0,s1
    80002f20:	00003097          	auipc	ra,0x3
    80002f24:	f52080e7          	jalr	-174(ra) # 80005e72 <virtio_disk_rw>
}
    80002f28:	60e2                	ld	ra,24(sp)
    80002f2a:	6442                	ld	s0,16(sp)
    80002f2c:	64a2                	ld	s1,8(sp)
    80002f2e:	6105                	addi	sp,sp,32
    80002f30:	8082                	ret
    panic("bwrite");
    80002f32:	00005517          	auipc	a0,0x5
    80002f36:	5f650513          	addi	a0,a0,1526 # 80008528 <syscalls+0xd8>
    80002f3a:	ffffd097          	auipc	ra,0xffffd
    80002f3e:	602080e7          	jalr	1538(ra) # 8000053c <panic>

0000000080002f42 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002f42:	1101                	addi	sp,sp,-32
    80002f44:	ec06                	sd	ra,24(sp)
    80002f46:	e822                	sd	s0,16(sp)
    80002f48:	e426                	sd	s1,8(sp)
    80002f4a:	e04a                	sd	s2,0(sp)
    80002f4c:	1000                	addi	s0,sp,32
    80002f4e:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002f50:	01050913          	addi	s2,a0,16
    80002f54:	854a                	mv	a0,s2
    80002f56:	00001097          	auipc	ra,0x1
    80002f5a:	3fc080e7          	jalr	1020(ra) # 80004352 <holdingsleep>
    80002f5e:	c925                	beqz	a0,80002fce <brelse+0x8c>
    panic("brelse");

  releasesleep(&b->lock);
    80002f60:	854a                	mv	a0,s2
    80002f62:	00001097          	auipc	ra,0x1
    80002f66:	3ac080e7          	jalr	940(ra) # 8000430e <releasesleep>

  acquire(&bcache.lock);
    80002f6a:	00014517          	auipc	a0,0x14
    80002f6e:	a0e50513          	addi	a0,a0,-1522 # 80016978 <bcache>
    80002f72:	ffffe097          	auipc	ra,0xffffe
    80002f76:	c60080e7          	jalr	-928(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80002f7a:	40bc                	lw	a5,64(s1)
    80002f7c:	37fd                	addiw	a5,a5,-1
    80002f7e:	0007871b          	sext.w	a4,a5
    80002f82:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002f84:	e71d                	bnez	a4,80002fb2 <brelse+0x70>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002f86:	68b8                	ld	a4,80(s1)
    80002f88:	64bc                	ld	a5,72(s1)
    80002f8a:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002f8c:	68b8                	ld	a4,80(s1)
    80002f8e:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002f90:	0001c797          	auipc	a5,0x1c
    80002f94:	9e878793          	addi	a5,a5,-1560 # 8001e978 <bcache+0x8000>
    80002f98:	2b87b703          	ld	a4,696(a5)
    80002f9c:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002f9e:	0001c717          	auipc	a4,0x1c
    80002fa2:	c4270713          	addi	a4,a4,-958 # 8001ebe0 <bcache+0x8268>
    80002fa6:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002fa8:	2b87b703          	ld	a4,696(a5)
    80002fac:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002fae:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002fb2:	00014517          	auipc	a0,0x14
    80002fb6:	9c650513          	addi	a0,a0,-1594 # 80016978 <bcache>
    80002fba:	ffffe097          	auipc	ra,0xffffe
    80002fbe:	ccc080e7          	jalr	-820(ra) # 80000c86 <release>
}
    80002fc2:	60e2                	ld	ra,24(sp)
    80002fc4:	6442                	ld	s0,16(sp)
    80002fc6:	64a2                	ld	s1,8(sp)
    80002fc8:	6902                	ld	s2,0(sp)
    80002fca:	6105                	addi	sp,sp,32
    80002fcc:	8082                	ret
    panic("brelse");
    80002fce:	00005517          	auipc	a0,0x5
    80002fd2:	56250513          	addi	a0,a0,1378 # 80008530 <syscalls+0xe0>
    80002fd6:	ffffd097          	auipc	ra,0xffffd
    80002fda:	566080e7          	jalr	1382(ra) # 8000053c <panic>

0000000080002fde <bpin>:

void
bpin(struct buf *b) {
    80002fde:	1101                	addi	sp,sp,-32
    80002fe0:	ec06                	sd	ra,24(sp)
    80002fe2:	e822                	sd	s0,16(sp)
    80002fe4:	e426                	sd	s1,8(sp)
    80002fe6:	1000                	addi	s0,sp,32
    80002fe8:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002fea:	00014517          	auipc	a0,0x14
    80002fee:	98e50513          	addi	a0,a0,-1650 # 80016978 <bcache>
    80002ff2:	ffffe097          	auipc	ra,0xffffe
    80002ff6:	be0080e7          	jalr	-1056(ra) # 80000bd2 <acquire>
  b->refcnt++;
    80002ffa:	40bc                	lw	a5,64(s1)
    80002ffc:	2785                	addiw	a5,a5,1
    80002ffe:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003000:	00014517          	auipc	a0,0x14
    80003004:	97850513          	addi	a0,a0,-1672 # 80016978 <bcache>
    80003008:	ffffe097          	auipc	ra,0xffffe
    8000300c:	c7e080e7          	jalr	-898(ra) # 80000c86 <release>
}
    80003010:	60e2                	ld	ra,24(sp)
    80003012:	6442                	ld	s0,16(sp)
    80003014:	64a2                	ld	s1,8(sp)
    80003016:	6105                	addi	sp,sp,32
    80003018:	8082                	ret

000000008000301a <bunpin>:

void
bunpin(struct buf *b) {
    8000301a:	1101                	addi	sp,sp,-32
    8000301c:	ec06                	sd	ra,24(sp)
    8000301e:	e822                	sd	s0,16(sp)
    80003020:	e426                	sd	s1,8(sp)
    80003022:	1000                	addi	s0,sp,32
    80003024:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80003026:	00014517          	auipc	a0,0x14
    8000302a:	95250513          	addi	a0,a0,-1710 # 80016978 <bcache>
    8000302e:	ffffe097          	auipc	ra,0xffffe
    80003032:	ba4080e7          	jalr	-1116(ra) # 80000bd2 <acquire>
  b->refcnt--;
    80003036:	40bc                	lw	a5,64(s1)
    80003038:	37fd                	addiw	a5,a5,-1
    8000303a:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000303c:	00014517          	auipc	a0,0x14
    80003040:	93c50513          	addi	a0,a0,-1732 # 80016978 <bcache>
    80003044:	ffffe097          	auipc	ra,0xffffe
    80003048:	c42080e7          	jalr	-958(ra) # 80000c86 <release>
}
    8000304c:	60e2                	ld	ra,24(sp)
    8000304e:	6442                	ld	s0,16(sp)
    80003050:	64a2                	ld	s1,8(sp)
    80003052:	6105                	addi	sp,sp,32
    80003054:	8082                	ret

0000000080003056 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80003056:	1101                	addi	sp,sp,-32
    80003058:	ec06                	sd	ra,24(sp)
    8000305a:	e822                	sd	s0,16(sp)
    8000305c:	e426                	sd	s1,8(sp)
    8000305e:	e04a                	sd	s2,0(sp)
    80003060:	1000                	addi	s0,sp,32
    80003062:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80003064:	00d5d59b          	srliw	a1,a1,0xd
    80003068:	0001c797          	auipc	a5,0x1c
    8000306c:	fec7a783          	lw	a5,-20(a5) # 8001f054 <sb+0x1c>
    80003070:	9dbd                	addw	a1,a1,a5
    80003072:	00000097          	auipc	ra,0x0
    80003076:	da0080e7          	jalr	-608(ra) # 80002e12 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    8000307a:	0074f713          	andi	a4,s1,7
    8000307e:	4785                	li	a5,1
    80003080:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80003084:	14ce                	slli	s1,s1,0x33
    80003086:	90d9                	srli	s1,s1,0x36
    80003088:	00950733          	add	a4,a0,s1
    8000308c:	05874703          	lbu	a4,88(a4)
    80003090:	00e7f6b3          	and	a3,a5,a4
    80003094:	c69d                	beqz	a3,800030c2 <bfree+0x6c>
    80003096:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80003098:	94aa                	add	s1,s1,a0
    8000309a:	fff7c793          	not	a5,a5
    8000309e:	8f7d                	and	a4,a4,a5
    800030a0:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    800030a4:	00001097          	auipc	ra,0x1
    800030a8:	0f6080e7          	jalr	246(ra) # 8000419a <log_write>
  brelse(bp);
    800030ac:	854a                	mv	a0,s2
    800030ae:	00000097          	auipc	ra,0x0
    800030b2:	e94080e7          	jalr	-364(ra) # 80002f42 <brelse>
}
    800030b6:	60e2                	ld	ra,24(sp)
    800030b8:	6442                	ld	s0,16(sp)
    800030ba:	64a2                	ld	s1,8(sp)
    800030bc:	6902                	ld	s2,0(sp)
    800030be:	6105                	addi	sp,sp,32
    800030c0:	8082                	ret
    panic("freeing free block");
    800030c2:	00005517          	auipc	a0,0x5
    800030c6:	47650513          	addi	a0,a0,1142 # 80008538 <syscalls+0xe8>
    800030ca:	ffffd097          	auipc	ra,0xffffd
    800030ce:	472080e7          	jalr	1138(ra) # 8000053c <panic>

00000000800030d2 <balloc>:
{
    800030d2:	711d                	addi	sp,sp,-96
    800030d4:	ec86                	sd	ra,88(sp)
    800030d6:	e8a2                	sd	s0,80(sp)
    800030d8:	e4a6                	sd	s1,72(sp)
    800030da:	e0ca                	sd	s2,64(sp)
    800030dc:	fc4e                	sd	s3,56(sp)
    800030de:	f852                	sd	s4,48(sp)
    800030e0:	f456                	sd	s5,40(sp)
    800030e2:	f05a                	sd	s6,32(sp)
    800030e4:	ec5e                	sd	s7,24(sp)
    800030e6:	e862                	sd	s8,16(sp)
    800030e8:	e466                	sd	s9,8(sp)
    800030ea:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800030ec:	0001c797          	auipc	a5,0x1c
    800030f0:	f507a783          	lw	a5,-176(a5) # 8001f03c <sb+0x4>
    800030f4:	cff5                	beqz	a5,800031f0 <balloc+0x11e>
    800030f6:	8baa                	mv	s7,a0
    800030f8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800030fa:	0001cb17          	auipc	s6,0x1c
    800030fe:	f3eb0b13          	addi	s6,s6,-194 # 8001f038 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003102:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80003104:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80003106:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80003108:	6c89                	lui	s9,0x2
    8000310a:	a061                	j	80003192 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    8000310c:	97ca                	add	a5,a5,s2
    8000310e:	8e55                	or	a2,a2,a3
    80003110:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80003114:	854a                	mv	a0,s2
    80003116:	00001097          	auipc	ra,0x1
    8000311a:	084080e7          	jalr	132(ra) # 8000419a <log_write>
        brelse(bp);
    8000311e:	854a                	mv	a0,s2
    80003120:	00000097          	auipc	ra,0x0
    80003124:	e22080e7          	jalr	-478(ra) # 80002f42 <brelse>
  bp = bread(dev, bno);
    80003128:	85a6                	mv	a1,s1
    8000312a:	855e                	mv	a0,s7
    8000312c:	00000097          	auipc	ra,0x0
    80003130:	ce6080e7          	jalr	-794(ra) # 80002e12 <bread>
    80003134:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80003136:	40000613          	li	a2,1024
    8000313a:	4581                	li	a1,0
    8000313c:	05850513          	addi	a0,a0,88
    80003140:	ffffe097          	auipc	ra,0xffffe
    80003144:	b8e080e7          	jalr	-1138(ra) # 80000cce <memset>
  log_write(bp);
    80003148:	854a                	mv	a0,s2
    8000314a:	00001097          	auipc	ra,0x1
    8000314e:	050080e7          	jalr	80(ra) # 8000419a <log_write>
  brelse(bp);
    80003152:	854a                	mv	a0,s2
    80003154:	00000097          	auipc	ra,0x0
    80003158:	dee080e7          	jalr	-530(ra) # 80002f42 <brelse>
}
    8000315c:	8526                	mv	a0,s1
    8000315e:	60e6                	ld	ra,88(sp)
    80003160:	6446                	ld	s0,80(sp)
    80003162:	64a6                	ld	s1,72(sp)
    80003164:	6906                	ld	s2,64(sp)
    80003166:	79e2                	ld	s3,56(sp)
    80003168:	7a42                	ld	s4,48(sp)
    8000316a:	7aa2                	ld	s5,40(sp)
    8000316c:	7b02                	ld	s6,32(sp)
    8000316e:	6be2                	ld	s7,24(sp)
    80003170:	6c42                	ld	s8,16(sp)
    80003172:	6ca2                	ld	s9,8(sp)
    80003174:	6125                	addi	sp,sp,96
    80003176:	8082                	ret
    brelse(bp);
    80003178:	854a                	mv	a0,s2
    8000317a:	00000097          	auipc	ra,0x0
    8000317e:	dc8080e7          	jalr	-568(ra) # 80002f42 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003182:	015c87bb          	addw	a5,s9,s5
    80003186:	00078a9b          	sext.w	s5,a5
    8000318a:	004b2703          	lw	a4,4(s6)
    8000318e:	06eaf163          	bgeu	s5,a4,800031f0 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003192:	41fad79b          	sraiw	a5,s5,0x1f
    80003196:	0137d79b          	srliw	a5,a5,0x13
    8000319a:	015787bb          	addw	a5,a5,s5
    8000319e:	40d7d79b          	sraiw	a5,a5,0xd
    800031a2:	01cb2583          	lw	a1,28(s6)
    800031a6:	9dbd                	addw	a1,a1,a5
    800031a8:	855e                	mv	a0,s7
    800031aa:	00000097          	auipc	ra,0x0
    800031ae:	c68080e7          	jalr	-920(ra) # 80002e12 <bread>
    800031b2:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031b4:	004b2503          	lw	a0,4(s6)
    800031b8:	000a849b          	sext.w	s1,s5
    800031bc:	8762                	mv	a4,s8
    800031be:	faa4fde3          	bgeu	s1,a0,80003178 <balloc+0xa6>
      m = 1 << (bi % 8);
    800031c2:	00777693          	andi	a3,a4,7
    800031c6:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800031ca:	41f7579b          	sraiw	a5,a4,0x1f
    800031ce:	01d7d79b          	srliw	a5,a5,0x1d
    800031d2:	9fb9                	addw	a5,a5,a4
    800031d4:	4037d79b          	sraiw	a5,a5,0x3
    800031d8:	00f90633          	add	a2,s2,a5
    800031dc:	05864603          	lbu	a2,88(a2)
    800031e0:	00c6f5b3          	and	a1,a3,a2
    800031e4:	d585                	beqz	a1,8000310c <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800031e6:	2705                	addiw	a4,a4,1
    800031e8:	2485                	addiw	s1,s1,1
    800031ea:	fd471ae3          	bne	a4,s4,800031be <balloc+0xec>
    800031ee:	b769                	j	80003178 <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800031f0:	00005517          	auipc	a0,0x5
    800031f4:	36050513          	addi	a0,a0,864 # 80008550 <syscalls+0x100>
    800031f8:	ffffd097          	auipc	ra,0xffffd
    800031fc:	38e080e7          	jalr	910(ra) # 80000586 <printf>
  return 0;
    80003200:	4481                	li	s1,0
    80003202:	bfa9                	j	8000315c <balloc+0x8a>

0000000080003204 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80003204:	7179                	addi	sp,sp,-48
    80003206:	f406                	sd	ra,40(sp)
    80003208:	f022                	sd	s0,32(sp)
    8000320a:	ec26                	sd	s1,24(sp)
    8000320c:	e84a                	sd	s2,16(sp)
    8000320e:	e44e                	sd	s3,8(sp)
    80003210:	e052                	sd	s4,0(sp)
    80003212:	1800                	addi	s0,sp,48
    80003214:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80003216:	47ad                	li	a5,11
    80003218:	02b7e863          	bltu	a5,a1,80003248 <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    8000321c:	02059793          	slli	a5,a1,0x20
    80003220:	01e7d593          	srli	a1,a5,0x1e
    80003224:	00b504b3          	add	s1,a0,a1
    80003228:	0504a903          	lw	s2,80(s1)
    8000322c:	06091e63          	bnez	s2,800032a8 <bmap+0xa4>
      addr = balloc(ip->dev);
    80003230:	4108                	lw	a0,0(a0)
    80003232:	00000097          	auipc	ra,0x0
    80003236:	ea0080e7          	jalr	-352(ra) # 800030d2 <balloc>
    8000323a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000323e:	06090563          	beqz	s2,800032a8 <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003242:	0524a823          	sw	s2,80(s1)
    80003246:	a08d                	j	800032a8 <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    80003248:	ff45849b          	addiw	s1,a1,-12
    8000324c:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003250:	0ff00793          	li	a5,255
    80003254:	08e7e563          	bltu	a5,a4,800032de <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80003258:	08052903          	lw	s2,128(a0)
    8000325c:	00091d63          	bnez	s2,80003276 <bmap+0x72>
      addr = balloc(ip->dev);
    80003260:	4108                	lw	a0,0(a0)
    80003262:	00000097          	auipc	ra,0x0
    80003266:	e70080e7          	jalr	-400(ra) # 800030d2 <balloc>
    8000326a:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    8000326e:	02090d63          	beqz	s2,800032a8 <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003272:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    80003276:	85ca                	mv	a1,s2
    80003278:	0009a503          	lw	a0,0(s3)
    8000327c:	00000097          	auipc	ra,0x0
    80003280:	b96080e7          	jalr	-1130(ra) # 80002e12 <bread>
    80003284:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80003286:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    8000328a:	02049713          	slli	a4,s1,0x20
    8000328e:	01e75593          	srli	a1,a4,0x1e
    80003292:	00b784b3          	add	s1,a5,a1
    80003296:	0004a903          	lw	s2,0(s1)
    8000329a:	02090063          	beqz	s2,800032ba <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    8000329e:	8552                	mv	a0,s4
    800032a0:	00000097          	auipc	ra,0x0
    800032a4:	ca2080e7          	jalr	-862(ra) # 80002f42 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    800032a8:	854a                	mv	a0,s2
    800032aa:	70a2                	ld	ra,40(sp)
    800032ac:	7402                	ld	s0,32(sp)
    800032ae:	64e2                	ld	s1,24(sp)
    800032b0:	6942                	ld	s2,16(sp)
    800032b2:	69a2                	ld	s3,8(sp)
    800032b4:	6a02                	ld	s4,0(sp)
    800032b6:	6145                	addi	sp,sp,48
    800032b8:	8082                	ret
      addr = balloc(ip->dev);
    800032ba:	0009a503          	lw	a0,0(s3)
    800032be:	00000097          	auipc	ra,0x0
    800032c2:	e14080e7          	jalr	-492(ra) # 800030d2 <balloc>
    800032c6:	0005091b          	sext.w	s2,a0
      if(addr){
    800032ca:	fc090ae3          	beqz	s2,8000329e <bmap+0x9a>
        a[bn] = addr;
    800032ce:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800032d2:	8552                	mv	a0,s4
    800032d4:	00001097          	auipc	ra,0x1
    800032d8:	ec6080e7          	jalr	-314(ra) # 8000419a <log_write>
    800032dc:	b7c9                	j	8000329e <bmap+0x9a>
  panic("bmap: out of range");
    800032de:	00005517          	auipc	a0,0x5
    800032e2:	28a50513          	addi	a0,a0,650 # 80008568 <syscalls+0x118>
    800032e6:	ffffd097          	auipc	ra,0xffffd
    800032ea:	256080e7          	jalr	598(ra) # 8000053c <panic>

00000000800032ee <iget>:
{
    800032ee:	7179                	addi	sp,sp,-48
    800032f0:	f406                	sd	ra,40(sp)
    800032f2:	f022                	sd	s0,32(sp)
    800032f4:	ec26                	sd	s1,24(sp)
    800032f6:	e84a                	sd	s2,16(sp)
    800032f8:	e44e                	sd	s3,8(sp)
    800032fa:	e052                	sd	s4,0(sp)
    800032fc:	1800                	addi	s0,sp,48
    800032fe:	89aa                	mv	s3,a0
    80003300:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80003302:	0001c517          	auipc	a0,0x1c
    80003306:	d5650513          	addi	a0,a0,-682 # 8001f058 <itable>
    8000330a:	ffffe097          	auipc	ra,0xffffe
    8000330e:	8c8080e7          	jalr	-1848(ra) # 80000bd2 <acquire>
  empty = 0;
    80003312:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003314:	0001c497          	auipc	s1,0x1c
    80003318:	d5c48493          	addi	s1,s1,-676 # 8001f070 <itable+0x18>
    8000331c:	0001d697          	auipc	a3,0x1d
    80003320:	7e468693          	addi	a3,a3,2020 # 80020b00 <log>
    80003324:	a039                	j	80003332 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003326:	02090b63          	beqz	s2,8000335c <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000332a:	08848493          	addi	s1,s1,136
    8000332e:	02d48a63          	beq	s1,a3,80003362 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003332:	449c                	lw	a5,8(s1)
    80003334:	fef059e3          	blez	a5,80003326 <iget+0x38>
    80003338:	4098                	lw	a4,0(s1)
    8000333a:	ff3716e3          	bne	a4,s3,80003326 <iget+0x38>
    8000333e:	40d8                	lw	a4,4(s1)
    80003340:	ff4713e3          	bne	a4,s4,80003326 <iget+0x38>
      ip->ref++;
    80003344:	2785                	addiw	a5,a5,1
    80003346:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    80003348:	0001c517          	auipc	a0,0x1c
    8000334c:	d1050513          	addi	a0,a0,-752 # 8001f058 <itable>
    80003350:	ffffe097          	auipc	ra,0xffffe
    80003354:	936080e7          	jalr	-1738(ra) # 80000c86 <release>
      return ip;
    80003358:	8926                	mv	s2,s1
    8000335a:	a03d                	j	80003388 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000335c:	f7f9                	bnez	a5,8000332a <iget+0x3c>
    8000335e:	8926                	mv	s2,s1
    80003360:	b7e9                	j	8000332a <iget+0x3c>
  if(empty == 0)
    80003362:	02090c63          	beqz	s2,8000339a <iget+0xac>
  ip->dev = dev;
    80003366:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    8000336a:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000336e:	4785                	li	a5,1
    80003370:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003374:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003378:	0001c517          	auipc	a0,0x1c
    8000337c:	ce050513          	addi	a0,a0,-800 # 8001f058 <itable>
    80003380:	ffffe097          	auipc	ra,0xffffe
    80003384:	906080e7          	jalr	-1786(ra) # 80000c86 <release>
}
    80003388:	854a                	mv	a0,s2
    8000338a:	70a2                	ld	ra,40(sp)
    8000338c:	7402                	ld	s0,32(sp)
    8000338e:	64e2                	ld	s1,24(sp)
    80003390:	6942                	ld	s2,16(sp)
    80003392:	69a2                	ld	s3,8(sp)
    80003394:	6a02                	ld	s4,0(sp)
    80003396:	6145                	addi	sp,sp,48
    80003398:	8082                	ret
    panic("iget: no inodes");
    8000339a:	00005517          	auipc	a0,0x5
    8000339e:	1e650513          	addi	a0,a0,486 # 80008580 <syscalls+0x130>
    800033a2:	ffffd097          	auipc	ra,0xffffd
    800033a6:	19a080e7          	jalr	410(ra) # 8000053c <panic>

00000000800033aa <fsinit>:
fsinit(int dev) {
    800033aa:	7179                	addi	sp,sp,-48
    800033ac:	f406                	sd	ra,40(sp)
    800033ae:	f022                	sd	s0,32(sp)
    800033b0:	ec26                	sd	s1,24(sp)
    800033b2:	e84a                	sd	s2,16(sp)
    800033b4:	e44e                	sd	s3,8(sp)
    800033b6:	1800                	addi	s0,sp,48
    800033b8:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800033ba:	4585                	li	a1,1
    800033bc:	00000097          	auipc	ra,0x0
    800033c0:	a56080e7          	jalr	-1450(ra) # 80002e12 <bread>
    800033c4:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800033c6:	0001c997          	auipc	s3,0x1c
    800033ca:	c7298993          	addi	s3,s3,-910 # 8001f038 <sb>
    800033ce:	02000613          	li	a2,32
    800033d2:	05850593          	addi	a1,a0,88
    800033d6:	854e                	mv	a0,s3
    800033d8:	ffffe097          	auipc	ra,0xffffe
    800033dc:	952080e7          	jalr	-1710(ra) # 80000d2a <memmove>
  brelse(bp);
    800033e0:	8526                	mv	a0,s1
    800033e2:	00000097          	auipc	ra,0x0
    800033e6:	b60080e7          	jalr	-1184(ra) # 80002f42 <brelse>
  if(sb.magic != FSMAGIC)
    800033ea:	0009a703          	lw	a4,0(s3)
    800033ee:	102037b7          	lui	a5,0x10203
    800033f2:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800033f6:	02f71263          	bne	a4,a5,8000341a <fsinit+0x70>
  initlog(dev, &sb);
    800033fa:	0001c597          	auipc	a1,0x1c
    800033fe:	c3e58593          	addi	a1,a1,-962 # 8001f038 <sb>
    80003402:	854a                	mv	a0,s2
    80003404:	00001097          	auipc	ra,0x1
    80003408:	b2c080e7          	jalr	-1236(ra) # 80003f30 <initlog>
}
    8000340c:	70a2                	ld	ra,40(sp)
    8000340e:	7402                	ld	s0,32(sp)
    80003410:	64e2                	ld	s1,24(sp)
    80003412:	6942                	ld	s2,16(sp)
    80003414:	69a2                	ld	s3,8(sp)
    80003416:	6145                	addi	sp,sp,48
    80003418:	8082                	ret
    panic("invalid file system");
    8000341a:	00005517          	auipc	a0,0x5
    8000341e:	17650513          	addi	a0,a0,374 # 80008590 <syscalls+0x140>
    80003422:	ffffd097          	auipc	ra,0xffffd
    80003426:	11a080e7          	jalr	282(ra) # 8000053c <panic>

000000008000342a <iinit>:
{
    8000342a:	7179                	addi	sp,sp,-48
    8000342c:	f406                	sd	ra,40(sp)
    8000342e:	f022                	sd	s0,32(sp)
    80003430:	ec26                	sd	s1,24(sp)
    80003432:	e84a                	sd	s2,16(sp)
    80003434:	e44e                	sd	s3,8(sp)
    80003436:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    80003438:	00005597          	auipc	a1,0x5
    8000343c:	17058593          	addi	a1,a1,368 # 800085a8 <syscalls+0x158>
    80003440:	0001c517          	auipc	a0,0x1c
    80003444:	c1850513          	addi	a0,a0,-1000 # 8001f058 <itable>
    80003448:	ffffd097          	auipc	ra,0xffffd
    8000344c:	6fa080e7          	jalr	1786(ra) # 80000b42 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003450:	0001c497          	auipc	s1,0x1c
    80003454:	c3048493          	addi	s1,s1,-976 # 8001f080 <itable+0x28>
    80003458:	0001d997          	auipc	s3,0x1d
    8000345c:	6b898993          	addi	s3,s3,1720 # 80020b10 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003460:	00005917          	auipc	s2,0x5
    80003464:	15090913          	addi	s2,s2,336 # 800085b0 <syscalls+0x160>
    80003468:	85ca                	mv	a1,s2
    8000346a:	8526                	mv	a0,s1
    8000346c:	00001097          	auipc	ra,0x1
    80003470:	e12080e7          	jalr	-494(ra) # 8000427e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80003474:	08848493          	addi	s1,s1,136
    80003478:	ff3498e3          	bne	s1,s3,80003468 <iinit+0x3e>
}
    8000347c:	70a2                	ld	ra,40(sp)
    8000347e:	7402                	ld	s0,32(sp)
    80003480:	64e2                	ld	s1,24(sp)
    80003482:	6942                	ld	s2,16(sp)
    80003484:	69a2                	ld	s3,8(sp)
    80003486:	6145                	addi	sp,sp,48
    80003488:	8082                	ret

000000008000348a <ialloc>:
{
    8000348a:	7139                	addi	sp,sp,-64
    8000348c:	fc06                	sd	ra,56(sp)
    8000348e:	f822                	sd	s0,48(sp)
    80003490:	f426                	sd	s1,40(sp)
    80003492:	f04a                	sd	s2,32(sp)
    80003494:	ec4e                	sd	s3,24(sp)
    80003496:	e852                	sd	s4,16(sp)
    80003498:	e456                	sd	s5,8(sp)
    8000349a:	e05a                	sd	s6,0(sp)
    8000349c:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000349e:	0001c717          	auipc	a4,0x1c
    800034a2:	ba672703          	lw	a4,-1114(a4) # 8001f044 <sb+0xc>
    800034a6:	4785                	li	a5,1
    800034a8:	04e7f863          	bgeu	a5,a4,800034f8 <ialloc+0x6e>
    800034ac:	8aaa                	mv	s5,a0
    800034ae:	8b2e                	mv	s6,a1
    800034b0:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    800034b2:	0001ca17          	auipc	s4,0x1c
    800034b6:	b86a0a13          	addi	s4,s4,-1146 # 8001f038 <sb>
    800034ba:	00495593          	srli	a1,s2,0x4
    800034be:	018a2783          	lw	a5,24(s4)
    800034c2:	9dbd                	addw	a1,a1,a5
    800034c4:	8556                	mv	a0,s5
    800034c6:	00000097          	auipc	ra,0x0
    800034ca:	94c080e7          	jalr	-1716(ra) # 80002e12 <bread>
    800034ce:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800034d0:	05850993          	addi	s3,a0,88
    800034d4:	00f97793          	andi	a5,s2,15
    800034d8:	079a                	slli	a5,a5,0x6
    800034da:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800034dc:	00099783          	lh	a5,0(s3)
    800034e0:	cf9d                	beqz	a5,8000351e <ialloc+0x94>
    brelse(bp);
    800034e2:	00000097          	auipc	ra,0x0
    800034e6:	a60080e7          	jalr	-1440(ra) # 80002f42 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800034ea:	0905                	addi	s2,s2,1
    800034ec:	00ca2703          	lw	a4,12(s4)
    800034f0:	0009079b          	sext.w	a5,s2
    800034f4:	fce7e3e3          	bltu	a5,a4,800034ba <ialloc+0x30>
  printf("ialloc: no inodes\n");
    800034f8:	00005517          	auipc	a0,0x5
    800034fc:	0c050513          	addi	a0,a0,192 # 800085b8 <syscalls+0x168>
    80003500:	ffffd097          	auipc	ra,0xffffd
    80003504:	086080e7          	jalr	134(ra) # 80000586 <printf>
  return 0;
    80003508:	4501                	li	a0,0
}
    8000350a:	70e2                	ld	ra,56(sp)
    8000350c:	7442                	ld	s0,48(sp)
    8000350e:	74a2                	ld	s1,40(sp)
    80003510:	7902                	ld	s2,32(sp)
    80003512:	69e2                	ld	s3,24(sp)
    80003514:	6a42                	ld	s4,16(sp)
    80003516:	6aa2                	ld	s5,8(sp)
    80003518:	6b02                	ld	s6,0(sp)
    8000351a:	6121                	addi	sp,sp,64
    8000351c:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000351e:	04000613          	li	a2,64
    80003522:	4581                	li	a1,0
    80003524:	854e                	mv	a0,s3
    80003526:	ffffd097          	auipc	ra,0xffffd
    8000352a:	7a8080e7          	jalr	1960(ra) # 80000cce <memset>
      dip->type = type;
    8000352e:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003532:	8526                	mv	a0,s1
    80003534:	00001097          	auipc	ra,0x1
    80003538:	c66080e7          	jalr	-922(ra) # 8000419a <log_write>
      brelse(bp);
    8000353c:	8526                	mv	a0,s1
    8000353e:	00000097          	auipc	ra,0x0
    80003542:	a04080e7          	jalr	-1532(ra) # 80002f42 <brelse>
      return iget(dev, inum);
    80003546:	0009059b          	sext.w	a1,s2
    8000354a:	8556                	mv	a0,s5
    8000354c:	00000097          	auipc	ra,0x0
    80003550:	da2080e7          	jalr	-606(ra) # 800032ee <iget>
    80003554:	bf5d                	j	8000350a <ialloc+0x80>

0000000080003556 <iupdate>:
{
    80003556:	1101                	addi	sp,sp,-32
    80003558:	ec06                	sd	ra,24(sp)
    8000355a:	e822                	sd	s0,16(sp)
    8000355c:	e426                	sd	s1,8(sp)
    8000355e:	e04a                	sd	s2,0(sp)
    80003560:	1000                	addi	s0,sp,32
    80003562:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003564:	415c                	lw	a5,4(a0)
    80003566:	0047d79b          	srliw	a5,a5,0x4
    8000356a:	0001c597          	auipc	a1,0x1c
    8000356e:	ae65a583          	lw	a1,-1306(a1) # 8001f050 <sb+0x18>
    80003572:	9dbd                	addw	a1,a1,a5
    80003574:	4108                	lw	a0,0(a0)
    80003576:	00000097          	auipc	ra,0x0
    8000357a:	89c080e7          	jalr	-1892(ra) # 80002e12 <bread>
    8000357e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003580:	05850793          	addi	a5,a0,88
    80003584:	40d8                	lw	a4,4(s1)
    80003586:	8b3d                	andi	a4,a4,15
    80003588:	071a                	slli	a4,a4,0x6
    8000358a:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    8000358c:	04449703          	lh	a4,68(s1)
    80003590:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003594:	04649703          	lh	a4,70(s1)
    80003598:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    8000359c:	04849703          	lh	a4,72(s1)
    800035a0:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800035a4:	04a49703          	lh	a4,74(s1)
    800035a8:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800035ac:	44f8                	lw	a4,76(s1)
    800035ae:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800035b0:	03400613          	li	a2,52
    800035b4:	05048593          	addi	a1,s1,80
    800035b8:	00c78513          	addi	a0,a5,12
    800035bc:	ffffd097          	auipc	ra,0xffffd
    800035c0:	76e080e7          	jalr	1902(ra) # 80000d2a <memmove>
  log_write(bp);
    800035c4:	854a                	mv	a0,s2
    800035c6:	00001097          	auipc	ra,0x1
    800035ca:	bd4080e7          	jalr	-1068(ra) # 8000419a <log_write>
  brelse(bp);
    800035ce:	854a                	mv	a0,s2
    800035d0:	00000097          	auipc	ra,0x0
    800035d4:	972080e7          	jalr	-1678(ra) # 80002f42 <brelse>
}
    800035d8:	60e2                	ld	ra,24(sp)
    800035da:	6442                	ld	s0,16(sp)
    800035dc:	64a2                	ld	s1,8(sp)
    800035de:	6902                	ld	s2,0(sp)
    800035e0:	6105                	addi	sp,sp,32
    800035e2:	8082                	ret

00000000800035e4 <idup>:
{
    800035e4:	1101                	addi	sp,sp,-32
    800035e6:	ec06                	sd	ra,24(sp)
    800035e8:	e822                	sd	s0,16(sp)
    800035ea:	e426                	sd	s1,8(sp)
    800035ec:	1000                	addi	s0,sp,32
    800035ee:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800035f0:	0001c517          	auipc	a0,0x1c
    800035f4:	a6850513          	addi	a0,a0,-1432 # 8001f058 <itable>
    800035f8:	ffffd097          	auipc	ra,0xffffd
    800035fc:	5da080e7          	jalr	1498(ra) # 80000bd2 <acquire>
  ip->ref++;
    80003600:	449c                	lw	a5,8(s1)
    80003602:	2785                	addiw	a5,a5,1
    80003604:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003606:	0001c517          	auipc	a0,0x1c
    8000360a:	a5250513          	addi	a0,a0,-1454 # 8001f058 <itable>
    8000360e:	ffffd097          	auipc	ra,0xffffd
    80003612:	678080e7          	jalr	1656(ra) # 80000c86 <release>
}
    80003616:	8526                	mv	a0,s1
    80003618:	60e2                	ld	ra,24(sp)
    8000361a:	6442                	ld	s0,16(sp)
    8000361c:	64a2                	ld	s1,8(sp)
    8000361e:	6105                	addi	sp,sp,32
    80003620:	8082                	ret

0000000080003622 <ilock>:
{
    80003622:	1101                	addi	sp,sp,-32
    80003624:	ec06                	sd	ra,24(sp)
    80003626:	e822                	sd	s0,16(sp)
    80003628:	e426                	sd	s1,8(sp)
    8000362a:	e04a                	sd	s2,0(sp)
    8000362c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000362e:	c115                	beqz	a0,80003652 <ilock+0x30>
    80003630:	84aa                	mv	s1,a0
    80003632:	451c                	lw	a5,8(a0)
    80003634:	00f05f63          	blez	a5,80003652 <ilock+0x30>
  acquiresleep(&ip->lock);
    80003638:	0541                	addi	a0,a0,16
    8000363a:	00001097          	auipc	ra,0x1
    8000363e:	c7e080e7          	jalr	-898(ra) # 800042b8 <acquiresleep>
  if(ip->valid == 0){
    80003642:	40bc                	lw	a5,64(s1)
    80003644:	cf99                	beqz	a5,80003662 <ilock+0x40>
}
    80003646:	60e2                	ld	ra,24(sp)
    80003648:	6442                	ld	s0,16(sp)
    8000364a:	64a2                	ld	s1,8(sp)
    8000364c:	6902                	ld	s2,0(sp)
    8000364e:	6105                	addi	sp,sp,32
    80003650:	8082                	ret
    panic("ilock");
    80003652:	00005517          	auipc	a0,0x5
    80003656:	f7e50513          	addi	a0,a0,-130 # 800085d0 <syscalls+0x180>
    8000365a:	ffffd097          	auipc	ra,0xffffd
    8000365e:	ee2080e7          	jalr	-286(ra) # 8000053c <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003662:	40dc                	lw	a5,4(s1)
    80003664:	0047d79b          	srliw	a5,a5,0x4
    80003668:	0001c597          	auipc	a1,0x1c
    8000366c:	9e85a583          	lw	a1,-1560(a1) # 8001f050 <sb+0x18>
    80003670:	9dbd                	addw	a1,a1,a5
    80003672:	4088                	lw	a0,0(s1)
    80003674:	fffff097          	auipc	ra,0xfffff
    80003678:	79e080e7          	jalr	1950(ra) # 80002e12 <bread>
    8000367c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000367e:	05850593          	addi	a1,a0,88
    80003682:	40dc                	lw	a5,4(s1)
    80003684:	8bbd                	andi	a5,a5,15
    80003686:	079a                	slli	a5,a5,0x6
    80003688:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    8000368a:	00059783          	lh	a5,0(a1)
    8000368e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80003692:	00259783          	lh	a5,2(a1)
    80003696:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    8000369a:	00459783          	lh	a5,4(a1)
    8000369e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    800036a2:	00659783          	lh	a5,6(a1)
    800036a6:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800036aa:	459c                	lw	a5,8(a1)
    800036ac:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800036ae:	03400613          	li	a2,52
    800036b2:	05b1                	addi	a1,a1,12
    800036b4:	05048513          	addi	a0,s1,80
    800036b8:	ffffd097          	auipc	ra,0xffffd
    800036bc:	672080e7          	jalr	1650(ra) # 80000d2a <memmove>
    brelse(bp);
    800036c0:	854a                	mv	a0,s2
    800036c2:	00000097          	auipc	ra,0x0
    800036c6:	880080e7          	jalr	-1920(ra) # 80002f42 <brelse>
    ip->valid = 1;
    800036ca:	4785                	li	a5,1
    800036cc:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800036ce:	04449783          	lh	a5,68(s1)
    800036d2:	fbb5                	bnez	a5,80003646 <ilock+0x24>
      panic("ilock: no type");
    800036d4:	00005517          	auipc	a0,0x5
    800036d8:	f0450513          	addi	a0,a0,-252 # 800085d8 <syscalls+0x188>
    800036dc:	ffffd097          	auipc	ra,0xffffd
    800036e0:	e60080e7          	jalr	-416(ra) # 8000053c <panic>

00000000800036e4 <iunlock>:
{
    800036e4:	1101                	addi	sp,sp,-32
    800036e6:	ec06                	sd	ra,24(sp)
    800036e8:	e822                	sd	s0,16(sp)
    800036ea:	e426                	sd	s1,8(sp)
    800036ec:	e04a                	sd	s2,0(sp)
    800036ee:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800036f0:	c905                	beqz	a0,80003720 <iunlock+0x3c>
    800036f2:	84aa                	mv	s1,a0
    800036f4:	01050913          	addi	s2,a0,16
    800036f8:	854a                	mv	a0,s2
    800036fa:	00001097          	auipc	ra,0x1
    800036fe:	c58080e7          	jalr	-936(ra) # 80004352 <holdingsleep>
    80003702:	cd19                	beqz	a0,80003720 <iunlock+0x3c>
    80003704:	449c                	lw	a5,8(s1)
    80003706:	00f05d63          	blez	a5,80003720 <iunlock+0x3c>
  releasesleep(&ip->lock);
    8000370a:	854a                	mv	a0,s2
    8000370c:	00001097          	auipc	ra,0x1
    80003710:	c02080e7          	jalr	-1022(ra) # 8000430e <releasesleep>
}
    80003714:	60e2                	ld	ra,24(sp)
    80003716:	6442                	ld	s0,16(sp)
    80003718:	64a2                	ld	s1,8(sp)
    8000371a:	6902                	ld	s2,0(sp)
    8000371c:	6105                	addi	sp,sp,32
    8000371e:	8082                	ret
    panic("iunlock");
    80003720:	00005517          	auipc	a0,0x5
    80003724:	ec850513          	addi	a0,a0,-312 # 800085e8 <syscalls+0x198>
    80003728:	ffffd097          	auipc	ra,0xffffd
    8000372c:	e14080e7          	jalr	-492(ra) # 8000053c <panic>

0000000080003730 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003730:	7179                	addi	sp,sp,-48
    80003732:	f406                	sd	ra,40(sp)
    80003734:	f022                	sd	s0,32(sp)
    80003736:	ec26                	sd	s1,24(sp)
    80003738:	e84a                	sd	s2,16(sp)
    8000373a:	e44e                	sd	s3,8(sp)
    8000373c:	e052                	sd	s4,0(sp)
    8000373e:	1800                	addi	s0,sp,48
    80003740:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003742:	05050493          	addi	s1,a0,80
    80003746:	08050913          	addi	s2,a0,128
    8000374a:	a021                	j	80003752 <itrunc+0x22>
    8000374c:	0491                	addi	s1,s1,4
    8000374e:	01248d63          	beq	s1,s2,80003768 <itrunc+0x38>
    if(ip->addrs[i]){
    80003752:	408c                	lw	a1,0(s1)
    80003754:	dde5                	beqz	a1,8000374c <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003756:	0009a503          	lw	a0,0(s3)
    8000375a:	00000097          	auipc	ra,0x0
    8000375e:	8fc080e7          	jalr	-1796(ra) # 80003056 <bfree>
      ip->addrs[i] = 0;
    80003762:	0004a023          	sw	zero,0(s1)
    80003766:	b7dd                	j	8000374c <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003768:	0809a583          	lw	a1,128(s3)
    8000376c:	e185                	bnez	a1,8000378c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    8000376e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003772:	854e                	mv	a0,s3
    80003774:	00000097          	auipc	ra,0x0
    80003778:	de2080e7          	jalr	-542(ra) # 80003556 <iupdate>
}
    8000377c:	70a2                	ld	ra,40(sp)
    8000377e:	7402                	ld	s0,32(sp)
    80003780:	64e2                	ld	s1,24(sp)
    80003782:	6942                	ld	s2,16(sp)
    80003784:	69a2                	ld	s3,8(sp)
    80003786:	6a02                	ld	s4,0(sp)
    80003788:	6145                	addi	sp,sp,48
    8000378a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    8000378c:	0009a503          	lw	a0,0(s3)
    80003790:	fffff097          	auipc	ra,0xfffff
    80003794:	682080e7          	jalr	1666(ra) # 80002e12 <bread>
    80003798:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    8000379a:	05850493          	addi	s1,a0,88
    8000379e:	45850913          	addi	s2,a0,1112
    800037a2:	a021                	j	800037aa <itrunc+0x7a>
    800037a4:	0491                	addi	s1,s1,4
    800037a6:	01248b63          	beq	s1,s2,800037bc <itrunc+0x8c>
      if(a[j])
    800037aa:	408c                	lw	a1,0(s1)
    800037ac:	dde5                	beqz	a1,800037a4 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    800037ae:	0009a503          	lw	a0,0(s3)
    800037b2:	00000097          	auipc	ra,0x0
    800037b6:	8a4080e7          	jalr	-1884(ra) # 80003056 <bfree>
    800037ba:	b7ed                	j	800037a4 <itrunc+0x74>
    brelse(bp);
    800037bc:	8552                	mv	a0,s4
    800037be:	fffff097          	auipc	ra,0xfffff
    800037c2:	784080e7          	jalr	1924(ra) # 80002f42 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    800037c6:	0809a583          	lw	a1,128(s3)
    800037ca:	0009a503          	lw	a0,0(s3)
    800037ce:	00000097          	auipc	ra,0x0
    800037d2:	888080e7          	jalr	-1912(ra) # 80003056 <bfree>
    ip->addrs[NDIRECT] = 0;
    800037d6:	0809a023          	sw	zero,128(s3)
    800037da:	bf51                	j	8000376e <itrunc+0x3e>

00000000800037dc <iput>:
{
    800037dc:	1101                	addi	sp,sp,-32
    800037de:	ec06                	sd	ra,24(sp)
    800037e0:	e822                	sd	s0,16(sp)
    800037e2:	e426                	sd	s1,8(sp)
    800037e4:	e04a                	sd	s2,0(sp)
    800037e6:	1000                	addi	s0,sp,32
    800037e8:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800037ea:	0001c517          	auipc	a0,0x1c
    800037ee:	86e50513          	addi	a0,a0,-1938 # 8001f058 <itable>
    800037f2:	ffffd097          	auipc	ra,0xffffd
    800037f6:	3e0080e7          	jalr	992(ra) # 80000bd2 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    800037fa:	4498                	lw	a4,8(s1)
    800037fc:	4785                	li	a5,1
    800037fe:	02f70363          	beq	a4,a5,80003824 <iput+0x48>
  ip->ref--;
    80003802:	449c                	lw	a5,8(s1)
    80003804:	37fd                	addiw	a5,a5,-1
    80003806:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003808:	0001c517          	auipc	a0,0x1c
    8000380c:	85050513          	addi	a0,a0,-1968 # 8001f058 <itable>
    80003810:	ffffd097          	auipc	ra,0xffffd
    80003814:	476080e7          	jalr	1142(ra) # 80000c86 <release>
}
    80003818:	60e2                	ld	ra,24(sp)
    8000381a:	6442                	ld	s0,16(sp)
    8000381c:	64a2                	ld	s1,8(sp)
    8000381e:	6902                	ld	s2,0(sp)
    80003820:	6105                	addi	sp,sp,32
    80003822:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003824:	40bc                	lw	a5,64(s1)
    80003826:	dff1                	beqz	a5,80003802 <iput+0x26>
    80003828:	04a49783          	lh	a5,74(s1)
    8000382c:	fbf9                	bnez	a5,80003802 <iput+0x26>
    acquiresleep(&ip->lock);
    8000382e:	01048913          	addi	s2,s1,16
    80003832:	854a                	mv	a0,s2
    80003834:	00001097          	auipc	ra,0x1
    80003838:	a84080e7          	jalr	-1404(ra) # 800042b8 <acquiresleep>
    release(&itable.lock);
    8000383c:	0001c517          	auipc	a0,0x1c
    80003840:	81c50513          	addi	a0,a0,-2020 # 8001f058 <itable>
    80003844:	ffffd097          	auipc	ra,0xffffd
    80003848:	442080e7          	jalr	1090(ra) # 80000c86 <release>
    itrunc(ip);
    8000384c:	8526                	mv	a0,s1
    8000384e:	00000097          	auipc	ra,0x0
    80003852:	ee2080e7          	jalr	-286(ra) # 80003730 <itrunc>
    ip->type = 0;
    80003856:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000385a:	8526                	mv	a0,s1
    8000385c:	00000097          	auipc	ra,0x0
    80003860:	cfa080e7          	jalr	-774(ra) # 80003556 <iupdate>
    ip->valid = 0;
    80003864:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003868:	854a                	mv	a0,s2
    8000386a:	00001097          	auipc	ra,0x1
    8000386e:	aa4080e7          	jalr	-1372(ra) # 8000430e <releasesleep>
    acquire(&itable.lock);
    80003872:	0001b517          	auipc	a0,0x1b
    80003876:	7e650513          	addi	a0,a0,2022 # 8001f058 <itable>
    8000387a:	ffffd097          	auipc	ra,0xffffd
    8000387e:	358080e7          	jalr	856(ra) # 80000bd2 <acquire>
    80003882:	b741                	j	80003802 <iput+0x26>

0000000080003884 <iunlockput>:
{
    80003884:	1101                	addi	sp,sp,-32
    80003886:	ec06                	sd	ra,24(sp)
    80003888:	e822                	sd	s0,16(sp)
    8000388a:	e426                	sd	s1,8(sp)
    8000388c:	1000                	addi	s0,sp,32
    8000388e:	84aa                	mv	s1,a0
  iunlock(ip);
    80003890:	00000097          	auipc	ra,0x0
    80003894:	e54080e7          	jalr	-428(ra) # 800036e4 <iunlock>
  iput(ip);
    80003898:	8526                	mv	a0,s1
    8000389a:	00000097          	auipc	ra,0x0
    8000389e:	f42080e7          	jalr	-190(ra) # 800037dc <iput>
}
    800038a2:	60e2                	ld	ra,24(sp)
    800038a4:	6442                	ld	s0,16(sp)
    800038a6:	64a2                	ld	s1,8(sp)
    800038a8:	6105                	addi	sp,sp,32
    800038aa:	8082                	ret

00000000800038ac <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800038ac:	1141                	addi	sp,sp,-16
    800038ae:	e422                	sd	s0,8(sp)
    800038b0:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800038b2:	411c                	lw	a5,0(a0)
    800038b4:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800038b6:	415c                	lw	a5,4(a0)
    800038b8:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800038ba:	04451783          	lh	a5,68(a0)
    800038be:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800038c2:	04a51783          	lh	a5,74(a0)
    800038c6:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800038ca:	04c56783          	lwu	a5,76(a0)
    800038ce:	e99c                	sd	a5,16(a1)
}
    800038d0:	6422                	ld	s0,8(sp)
    800038d2:	0141                	addi	sp,sp,16
    800038d4:	8082                	ret

00000000800038d6 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800038d6:	457c                	lw	a5,76(a0)
    800038d8:	0ed7e963          	bltu	a5,a3,800039ca <readi+0xf4>
{
    800038dc:	7159                	addi	sp,sp,-112
    800038de:	f486                	sd	ra,104(sp)
    800038e0:	f0a2                	sd	s0,96(sp)
    800038e2:	eca6                	sd	s1,88(sp)
    800038e4:	e8ca                	sd	s2,80(sp)
    800038e6:	e4ce                	sd	s3,72(sp)
    800038e8:	e0d2                	sd	s4,64(sp)
    800038ea:	fc56                	sd	s5,56(sp)
    800038ec:	f85a                	sd	s6,48(sp)
    800038ee:	f45e                	sd	s7,40(sp)
    800038f0:	f062                	sd	s8,32(sp)
    800038f2:	ec66                	sd	s9,24(sp)
    800038f4:	e86a                	sd	s10,16(sp)
    800038f6:	e46e                	sd	s11,8(sp)
    800038f8:	1880                	addi	s0,sp,112
    800038fa:	8b2a                	mv	s6,a0
    800038fc:	8bae                	mv	s7,a1
    800038fe:	8a32                	mv	s4,a2
    80003900:	84b6                	mv	s1,a3
    80003902:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003904:	9f35                	addw	a4,a4,a3
    return 0;
    80003906:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003908:	0ad76063          	bltu	a4,a3,800039a8 <readi+0xd2>
  if(off + n > ip->size)
    8000390c:	00e7f463          	bgeu	a5,a4,80003914 <readi+0x3e>
    n = ip->size - off;
    80003910:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003914:	0a0a8963          	beqz	s5,800039c6 <readi+0xf0>
    80003918:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000391a:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    8000391e:	5c7d                	li	s8,-1
    80003920:	a82d                	j	8000395a <readi+0x84>
    80003922:	020d1d93          	slli	s11,s10,0x20
    80003926:	020ddd93          	srli	s11,s11,0x20
    8000392a:	05890613          	addi	a2,s2,88
    8000392e:	86ee                	mv	a3,s11
    80003930:	963a                	add	a2,a2,a4
    80003932:	85d2                	mv	a1,s4
    80003934:	855e                	mv	a0,s7
    80003936:	fffff097          	auipc	ra,0xfffff
    8000393a:	b20080e7          	jalr	-1248(ra) # 80002456 <either_copyout>
    8000393e:	05850d63          	beq	a0,s8,80003998 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003942:	854a                	mv	a0,s2
    80003944:	fffff097          	auipc	ra,0xfffff
    80003948:	5fe080e7          	jalr	1534(ra) # 80002f42 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000394c:	013d09bb          	addw	s3,s10,s3
    80003950:	009d04bb          	addw	s1,s10,s1
    80003954:	9a6e                	add	s4,s4,s11
    80003956:	0559f763          	bgeu	s3,s5,800039a4 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    8000395a:	00a4d59b          	srliw	a1,s1,0xa
    8000395e:	855a                	mv	a0,s6
    80003960:	00000097          	auipc	ra,0x0
    80003964:	8a4080e7          	jalr	-1884(ra) # 80003204 <bmap>
    80003968:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    8000396c:	cd85                	beqz	a1,800039a4 <readi+0xce>
    bp = bread(ip->dev, addr);
    8000396e:	000b2503          	lw	a0,0(s6)
    80003972:	fffff097          	auipc	ra,0xfffff
    80003976:	4a0080e7          	jalr	1184(ra) # 80002e12 <bread>
    8000397a:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000397c:	3ff4f713          	andi	a4,s1,1023
    80003980:	40ec87bb          	subw	a5,s9,a4
    80003984:	413a86bb          	subw	a3,s5,s3
    80003988:	8d3e                	mv	s10,a5
    8000398a:	2781                	sext.w	a5,a5
    8000398c:	0006861b          	sext.w	a2,a3
    80003990:	f8f679e3          	bgeu	a2,a5,80003922 <readi+0x4c>
    80003994:	8d36                	mv	s10,a3
    80003996:	b771                	j	80003922 <readi+0x4c>
      brelse(bp);
    80003998:	854a                	mv	a0,s2
    8000399a:	fffff097          	auipc	ra,0xfffff
    8000399e:	5a8080e7          	jalr	1448(ra) # 80002f42 <brelse>
      tot = -1;
    800039a2:	59fd                	li	s3,-1
  }
  return tot;
    800039a4:	0009851b          	sext.w	a0,s3
}
    800039a8:	70a6                	ld	ra,104(sp)
    800039aa:	7406                	ld	s0,96(sp)
    800039ac:	64e6                	ld	s1,88(sp)
    800039ae:	6946                	ld	s2,80(sp)
    800039b0:	69a6                	ld	s3,72(sp)
    800039b2:	6a06                	ld	s4,64(sp)
    800039b4:	7ae2                	ld	s5,56(sp)
    800039b6:	7b42                	ld	s6,48(sp)
    800039b8:	7ba2                	ld	s7,40(sp)
    800039ba:	7c02                	ld	s8,32(sp)
    800039bc:	6ce2                	ld	s9,24(sp)
    800039be:	6d42                	ld	s10,16(sp)
    800039c0:	6da2                	ld	s11,8(sp)
    800039c2:	6165                	addi	sp,sp,112
    800039c4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800039c6:	89d6                	mv	s3,s5
    800039c8:	bff1                	j	800039a4 <readi+0xce>
    return 0;
    800039ca:	4501                	li	a0,0
}
    800039cc:	8082                	ret

00000000800039ce <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800039ce:	457c                	lw	a5,76(a0)
    800039d0:	10d7e863          	bltu	a5,a3,80003ae0 <writei+0x112>
{
    800039d4:	7159                	addi	sp,sp,-112
    800039d6:	f486                	sd	ra,104(sp)
    800039d8:	f0a2                	sd	s0,96(sp)
    800039da:	eca6                	sd	s1,88(sp)
    800039dc:	e8ca                	sd	s2,80(sp)
    800039de:	e4ce                	sd	s3,72(sp)
    800039e0:	e0d2                	sd	s4,64(sp)
    800039e2:	fc56                	sd	s5,56(sp)
    800039e4:	f85a                	sd	s6,48(sp)
    800039e6:	f45e                	sd	s7,40(sp)
    800039e8:	f062                	sd	s8,32(sp)
    800039ea:	ec66                	sd	s9,24(sp)
    800039ec:	e86a                	sd	s10,16(sp)
    800039ee:	e46e                	sd	s11,8(sp)
    800039f0:	1880                	addi	s0,sp,112
    800039f2:	8aaa                	mv	s5,a0
    800039f4:	8bae                	mv	s7,a1
    800039f6:	8a32                	mv	s4,a2
    800039f8:	8936                	mv	s2,a3
    800039fa:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    800039fc:	00e687bb          	addw	a5,a3,a4
    80003a00:	0ed7e263          	bltu	a5,a3,80003ae4 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003a04:	00043737          	lui	a4,0x43
    80003a08:	0ef76063          	bltu	a4,a5,80003ae8 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a0c:	0c0b0863          	beqz	s6,80003adc <writei+0x10e>
    80003a10:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a12:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003a16:	5c7d                	li	s8,-1
    80003a18:	a091                	j	80003a5c <writei+0x8e>
    80003a1a:	020d1d93          	slli	s11,s10,0x20
    80003a1e:	020ddd93          	srli	s11,s11,0x20
    80003a22:	05848513          	addi	a0,s1,88
    80003a26:	86ee                	mv	a3,s11
    80003a28:	8652                	mv	a2,s4
    80003a2a:	85de                	mv	a1,s7
    80003a2c:	953a                	add	a0,a0,a4
    80003a2e:	fffff097          	auipc	ra,0xfffff
    80003a32:	a7e080e7          	jalr	-1410(ra) # 800024ac <either_copyin>
    80003a36:	07850263          	beq	a0,s8,80003a9a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	00000097          	auipc	ra,0x0
    80003a40:	75e080e7          	jalr	1886(ra) # 8000419a <log_write>
    brelse(bp);
    80003a44:	8526                	mv	a0,s1
    80003a46:	fffff097          	auipc	ra,0xfffff
    80003a4a:	4fc080e7          	jalr	1276(ra) # 80002f42 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003a4e:	013d09bb          	addw	s3,s10,s3
    80003a52:	012d093b          	addw	s2,s10,s2
    80003a56:	9a6e                	add	s4,s4,s11
    80003a58:	0569f663          	bgeu	s3,s6,80003aa4 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003a5c:	00a9559b          	srliw	a1,s2,0xa
    80003a60:	8556                	mv	a0,s5
    80003a62:	fffff097          	auipc	ra,0xfffff
    80003a66:	7a2080e7          	jalr	1954(ra) # 80003204 <bmap>
    80003a6a:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003a6e:	c99d                	beqz	a1,80003aa4 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003a70:	000aa503          	lw	a0,0(s5)
    80003a74:	fffff097          	auipc	ra,0xfffff
    80003a78:	39e080e7          	jalr	926(ra) # 80002e12 <bread>
    80003a7c:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003a7e:	3ff97713          	andi	a4,s2,1023
    80003a82:	40ec87bb          	subw	a5,s9,a4
    80003a86:	413b06bb          	subw	a3,s6,s3
    80003a8a:	8d3e                	mv	s10,a5
    80003a8c:	2781                	sext.w	a5,a5
    80003a8e:	0006861b          	sext.w	a2,a3
    80003a92:	f8f674e3          	bgeu	a2,a5,80003a1a <writei+0x4c>
    80003a96:	8d36                	mv	s10,a3
    80003a98:	b749                	j	80003a1a <writei+0x4c>
      brelse(bp);
    80003a9a:	8526                	mv	a0,s1
    80003a9c:	fffff097          	auipc	ra,0xfffff
    80003aa0:	4a6080e7          	jalr	1190(ra) # 80002f42 <brelse>
  }

  if(off > ip->size)
    80003aa4:	04caa783          	lw	a5,76(s5)
    80003aa8:	0127f463          	bgeu	a5,s2,80003ab0 <writei+0xe2>
    ip->size = off;
    80003aac:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003ab0:	8556                	mv	a0,s5
    80003ab2:	00000097          	auipc	ra,0x0
    80003ab6:	aa4080e7          	jalr	-1372(ra) # 80003556 <iupdate>

  return tot;
    80003aba:	0009851b          	sext.w	a0,s3
}
    80003abe:	70a6                	ld	ra,104(sp)
    80003ac0:	7406                	ld	s0,96(sp)
    80003ac2:	64e6                	ld	s1,88(sp)
    80003ac4:	6946                	ld	s2,80(sp)
    80003ac6:	69a6                	ld	s3,72(sp)
    80003ac8:	6a06                	ld	s4,64(sp)
    80003aca:	7ae2                	ld	s5,56(sp)
    80003acc:	7b42                	ld	s6,48(sp)
    80003ace:	7ba2                	ld	s7,40(sp)
    80003ad0:	7c02                	ld	s8,32(sp)
    80003ad2:	6ce2                	ld	s9,24(sp)
    80003ad4:	6d42                	ld	s10,16(sp)
    80003ad6:	6da2                	ld	s11,8(sp)
    80003ad8:	6165                	addi	sp,sp,112
    80003ada:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003adc:	89da                	mv	s3,s6
    80003ade:	bfc9                	j	80003ab0 <writei+0xe2>
    return -1;
    80003ae0:	557d                	li	a0,-1
}
    80003ae2:	8082                	ret
    return -1;
    80003ae4:	557d                	li	a0,-1
    80003ae6:	bfe1                	j	80003abe <writei+0xf0>
    return -1;
    80003ae8:	557d                	li	a0,-1
    80003aea:	bfd1                	j	80003abe <writei+0xf0>

0000000080003aec <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003aec:	1141                	addi	sp,sp,-16
    80003aee:	e406                	sd	ra,8(sp)
    80003af0:	e022                	sd	s0,0(sp)
    80003af2:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003af4:	4639                	li	a2,14
    80003af6:	ffffd097          	auipc	ra,0xffffd
    80003afa:	2a8080e7          	jalr	680(ra) # 80000d9e <strncmp>
}
    80003afe:	60a2                	ld	ra,8(sp)
    80003b00:	6402                	ld	s0,0(sp)
    80003b02:	0141                	addi	sp,sp,16
    80003b04:	8082                	ret

0000000080003b06 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003b06:	7139                	addi	sp,sp,-64
    80003b08:	fc06                	sd	ra,56(sp)
    80003b0a:	f822                	sd	s0,48(sp)
    80003b0c:	f426                	sd	s1,40(sp)
    80003b0e:	f04a                	sd	s2,32(sp)
    80003b10:	ec4e                	sd	s3,24(sp)
    80003b12:	e852                	sd	s4,16(sp)
    80003b14:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003b16:	04451703          	lh	a4,68(a0)
    80003b1a:	4785                	li	a5,1
    80003b1c:	00f71a63          	bne	a4,a5,80003b30 <dirlookup+0x2a>
    80003b20:	892a                	mv	s2,a0
    80003b22:	89ae                	mv	s3,a1
    80003b24:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b26:	457c                	lw	a5,76(a0)
    80003b28:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003b2a:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b2c:	e79d                	bnez	a5,80003b5a <dirlookup+0x54>
    80003b2e:	a8a5                	j	80003ba6 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003b30:	00005517          	auipc	a0,0x5
    80003b34:	ac050513          	addi	a0,a0,-1344 # 800085f0 <syscalls+0x1a0>
    80003b38:	ffffd097          	auipc	ra,0xffffd
    80003b3c:	a04080e7          	jalr	-1532(ra) # 8000053c <panic>
      panic("dirlookup read");
    80003b40:	00005517          	auipc	a0,0x5
    80003b44:	ac850513          	addi	a0,a0,-1336 # 80008608 <syscalls+0x1b8>
    80003b48:	ffffd097          	auipc	ra,0xffffd
    80003b4c:	9f4080e7          	jalr	-1548(ra) # 8000053c <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003b50:	24c1                	addiw	s1,s1,16
    80003b52:	04c92783          	lw	a5,76(s2)
    80003b56:	04f4f763          	bgeu	s1,a5,80003ba4 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003b5a:	4741                	li	a4,16
    80003b5c:	86a6                	mv	a3,s1
    80003b5e:	fc040613          	addi	a2,s0,-64
    80003b62:	4581                	li	a1,0
    80003b64:	854a                	mv	a0,s2
    80003b66:	00000097          	auipc	ra,0x0
    80003b6a:	d70080e7          	jalr	-656(ra) # 800038d6 <readi>
    80003b6e:	47c1                	li	a5,16
    80003b70:	fcf518e3          	bne	a0,a5,80003b40 <dirlookup+0x3a>
    if(de.inum == 0)
    80003b74:	fc045783          	lhu	a5,-64(s0)
    80003b78:	dfe1                	beqz	a5,80003b50 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003b7a:	fc240593          	addi	a1,s0,-62
    80003b7e:	854e                	mv	a0,s3
    80003b80:	00000097          	auipc	ra,0x0
    80003b84:	f6c080e7          	jalr	-148(ra) # 80003aec <namecmp>
    80003b88:	f561                	bnez	a0,80003b50 <dirlookup+0x4a>
      if(poff)
    80003b8a:	000a0463          	beqz	s4,80003b92 <dirlookup+0x8c>
        *poff = off;
    80003b8e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003b92:	fc045583          	lhu	a1,-64(s0)
    80003b96:	00092503          	lw	a0,0(s2)
    80003b9a:	fffff097          	auipc	ra,0xfffff
    80003b9e:	754080e7          	jalr	1876(ra) # 800032ee <iget>
    80003ba2:	a011                	j	80003ba6 <dirlookup+0xa0>
  return 0;
    80003ba4:	4501                	li	a0,0
}
    80003ba6:	70e2                	ld	ra,56(sp)
    80003ba8:	7442                	ld	s0,48(sp)
    80003baa:	74a2                	ld	s1,40(sp)
    80003bac:	7902                	ld	s2,32(sp)
    80003bae:	69e2                	ld	s3,24(sp)
    80003bb0:	6a42                	ld	s4,16(sp)
    80003bb2:	6121                	addi	sp,sp,64
    80003bb4:	8082                	ret

0000000080003bb6 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003bb6:	711d                	addi	sp,sp,-96
    80003bb8:	ec86                	sd	ra,88(sp)
    80003bba:	e8a2                	sd	s0,80(sp)
    80003bbc:	e4a6                	sd	s1,72(sp)
    80003bbe:	e0ca                	sd	s2,64(sp)
    80003bc0:	fc4e                	sd	s3,56(sp)
    80003bc2:	f852                	sd	s4,48(sp)
    80003bc4:	f456                	sd	s5,40(sp)
    80003bc6:	f05a                	sd	s6,32(sp)
    80003bc8:	ec5e                	sd	s7,24(sp)
    80003bca:	e862                	sd	s8,16(sp)
    80003bcc:	e466                	sd	s9,8(sp)
    80003bce:	1080                	addi	s0,sp,96
    80003bd0:	84aa                	mv	s1,a0
    80003bd2:	8b2e                	mv	s6,a1
    80003bd4:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003bd6:	00054703          	lbu	a4,0(a0)
    80003bda:	02f00793          	li	a5,47
    80003bde:	02f70263          	beq	a4,a5,80003c02 <namex+0x4c>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003be2:	ffffe097          	auipc	ra,0xffffe
    80003be6:	dc4080e7          	jalr	-572(ra) # 800019a6 <myproc>
    80003bea:	15053503          	ld	a0,336(a0)
    80003bee:	00000097          	auipc	ra,0x0
    80003bf2:	9f6080e7          	jalr	-1546(ra) # 800035e4 <idup>
    80003bf6:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003bf8:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003bfc:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003bfe:	4b85                	li	s7,1
    80003c00:	a875                	j	80003cbc <namex+0x106>
    ip = iget(ROOTDEV, ROOTINO);
    80003c02:	4585                	li	a1,1
    80003c04:	4505                	li	a0,1
    80003c06:	fffff097          	auipc	ra,0xfffff
    80003c0a:	6e8080e7          	jalr	1768(ra) # 800032ee <iget>
    80003c0e:	8a2a                	mv	s4,a0
    80003c10:	b7e5                	j	80003bf8 <namex+0x42>
      iunlockput(ip);
    80003c12:	8552                	mv	a0,s4
    80003c14:	00000097          	auipc	ra,0x0
    80003c18:	c70080e7          	jalr	-912(ra) # 80003884 <iunlockput>
      return 0;
    80003c1c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003c1e:	8552                	mv	a0,s4
    80003c20:	60e6                	ld	ra,88(sp)
    80003c22:	6446                	ld	s0,80(sp)
    80003c24:	64a6                	ld	s1,72(sp)
    80003c26:	6906                	ld	s2,64(sp)
    80003c28:	79e2                	ld	s3,56(sp)
    80003c2a:	7a42                	ld	s4,48(sp)
    80003c2c:	7aa2                	ld	s5,40(sp)
    80003c2e:	7b02                	ld	s6,32(sp)
    80003c30:	6be2                	ld	s7,24(sp)
    80003c32:	6c42                	ld	s8,16(sp)
    80003c34:	6ca2                	ld	s9,8(sp)
    80003c36:	6125                	addi	sp,sp,96
    80003c38:	8082                	ret
      iunlock(ip);
    80003c3a:	8552                	mv	a0,s4
    80003c3c:	00000097          	auipc	ra,0x0
    80003c40:	aa8080e7          	jalr	-1368(ra) # 800036e4 <iunlock>
      return ip;
    80003c44:	bfe9                	j	80003c1e <namex+0x68>
      iunlockput(ip);
    80003c46:	8552                	mv	a0,s4
    80003c48:	00000097          	auipc	ra,0x0
    80003c4c:	c3c080e7          	jalr	-964(ra) # 80003884 <iunlockput>
      return 0;
    80003c50:	8a4e                	mv	s4,s3
    80003c52:	b7f1                	j	80003c1e <namex+0x68>
  len = path - s;
    80003c54:	40998633          	sub	a2,s3,s1
    80003c58:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003c5c:	099c5863          	bge	s8,s9,80003cec <namex+0x136>
    memmove(name, s, DIRSIZ);
    80003c60:	4639                	li	a2,14
    80003c62:	85a6                	mv	a1,s1
    80003c64:	8556                	mv	a0,s5
    80003c66:	ffffd097          	auipc	ra,0xffffd
    80003c6a:	0c4080e7          	jalr	196(ra) # 80000d2a <memmove>
    80003c6e:	84ce                	mv	s1,s3
  while(*path == '/')
    80003c70:	0004c783          	lbu	a5,0(s1)
    80003c74:	01279763          	bne	a5,s2,80003c82 <namex+0xcc>
    path++;
    80003c78:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003c7a:	0004c783          	lbu	a5,0(s1)
    80003c7e:	ff278de3          	beq	a5,s2,80003c78 <namex+0xc2>
    ilock(ip);
    80003c82:	8552                	mv	a0,s4
    80003c84:	00000097          	auipc	ra,0x0
    80003c88:	99e080e7          	jalr	-1634(ra) # 80003622 <ilock>
    if(ip->type != T_DIR){
    80003c8c:	044a1783          	lh	a5,68(s4)
    80003c90:	f97791e3          	bne	a5,s7,80003c12 <namex+0x5c>
    if(nameiparent && *path == '\0'){
    80003c94:	000b0563          	beqz	s6,80003c9e <namex+0xe8>
    80003c98:	0004c783          	lbu	a5,0(s1)
    80003c9c:	dfd9                	beqz	a5,80003c3a <namex+0x84>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003c9e:	4601                	li	a2,0
    80003ca0:	85d6                	mv	a1,s5
    80003ca2:	8552                	mv	a0,s4
    80003ca4:	00000097          	auipc	ra,0x0
    80003ca8:	e62080e7          	jalr	-414(ra) # 80003b06 <dirlookup>
    80003cac:	89aa                	mv	s3,a0
    80003cae:	dd41                	beqz	a0,80003c46 <namex+0x90>
    iunlockput(ip);
    80003cb0:	8552                	mv	a0,s4
    80003cb2:	00000097          	auipc	ra,0x0
    80003cb6:	bd2080e7          	jalr	-1070(ra) # 80003884 <iunlockput>
    ip = next;
    80003cba:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003cbc:	0004c783          	lbu	a5,0(s1)
    80003cc0:	01279763          	bne	a5,s2,80003cce <namex+0x118>
    path++;
    80003cc4:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003cc6:	0004c783          	lbu	a5,0(s1)
    80003cca:	ff278de3          	beq	a5,s2,80003cc4 <namex+0x10e>
  if(*path == 0)
    80003cce:	cb9d                	beqz	a5,80003d04 <namex+0x14e>
  while(*path != '/' && *path != 0)
    80003cd0:	0004c783          	lbu	a5,0(s1)
    80003cd4:	89a6                	mv	s3,s1
  len = path - s;
    80003cd6:	4c81                	li	s9,0
    80003cd8:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    80003cda:	01278963          	beq	a5,s2,80003cec <namex+0x136>
    80003cde:	dbbd                	beqz	a5,80003c54 <namex+0x9e>
    path++;
    80003ce0:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003ce2:	0009c783          	lbu	a5,0(s3)
    80003ce6:	ff279ce3          	bne	a5,s2,80003cde <namex+0x128>
    80003cea:	b7ad                	j	80003c54 <namex+0x9e>
    memmove(name, s, len);
    80003cec:	2601                	sext.w	a2,a2
    80003cee:	85a6                	mv	a1,s1
    80003cf0:	8556                	mv	a0,s5
    80003cf2:	ffffd097          	auipc	ra,0xffffd
    80003cf6:	038080e7          	jalr	56(ra) # 80000d2a <memmove>
    name[len] = 0;
    80003cfa:	9cd6                	add	s9,s9,s5
    80003cfc:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    80003d00:	84ce                	mv	s1,s3
    80003d02:	b7bd                	j	80003c70 <namex+0xba>
  if(nameiparent){
    80003d04:	f00b0de3          	beqz	s6,80003c1e <namex+0x68>
    iput(ip);
    80003d08:	8552                	mv	a0,s4
    80003d0a:	00000097          	auipc	ra,0x0
    80003d0e:	ad2080e7          	jalr	-1326(ra) # 800037dc <iput>
    return 0;
    80003d12:	4a01                	li	s4,0
    80003d14:	b729                	j	80003c1e <namex+0x68>

0000000080003d16 <dirlink>:
{
    80003d16:	7139                	addi	sp,sp,-64
    80003d18:	fc06                	sd	ra,56(sp)
    80003d1a:	f822                	sd	s0,48(sp)
    80003d1c:	f426                	sd	s1,40(sp)
    80003d1e:	f04a                	sd	s2,32(sp)
    80003d20:	ec4e                	sd	s3,24(sp)
    80003d22:	e852                	sd	s4,16(sp)
    80003d24:	0080                	addi	s0,sp,64
    80003d26:	892a                	mv	s2,a0
    80003d28:	8a2e                	mv	s4,a1
    80003d2a:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    80003d2c:	4601                	li	a2,0
    80003d2e:	00000097          	auipc	ra,0x0
    80003d32:	dd8080e7          	jalr	-552(ra) # 80003b06 <dirlookup>
    80003d36:	e93d                	bnez	a0,80003dac <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d38:	04c92483          	lw	s1,76(s2)
    80003d3c:	c49d                	beqz	s1,80003d6a <dirlink+0x54>
    80003d3e:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d40:	4741                	li	a4,16
    80003d42:	86a6                	mv	a3,s1
    80003d44:	fc040613          	addi	a2,s0,-64
    80003d48:	4581                	li	a1,0
    80003d4a:	854a                	mv	a0,s2
    80003d4c:	00000097          	auipc	ra,0x0
    80003d50:	b8a080e7          	jalr	-1142(ra) # 800038d6 <readi>
    80003d54:	47c1                	li	a5,16
    80003d56:	06f51163          	bne	a0,a5,80003db8 <dirlink+0xa2>
    if(de.inum == 0)
    80003d5a:	fc045783          	lhu	a5,-64(s0)
    80003d5e:	c791                	beqz	a5,80003d6a <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003d60:	24c1                	addiw	s1,s1,16
    80003d62:	04c92783          	lw	a5,76(s2)
    80003d66:	fcf4ede3          	bltu	s1,a5,80003d40 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003d6a:	4639                	li	a2,14
    80003d6c:	85d2                	mv	a1,s4
    80003d6e:	fc240513          	addi	a0,s0,-62
    80003d72:	ffffd097          	auipc	ra,0xffffd
    80003d76:	068080e7          	jalr	104(ra) # 80000dda <strncpy>
  de.inum = inum;
    80003d7a:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003d7e:	4741                	li	a4,16
    80003d80:	86a6                	mv	a3,s1
    80003d82:	fc040613          	addi	a2,s0,-64
    80003d86:	4581                	li	a1,0
    80003d88:	854a                	mv	a0,s2
    80003d8a:	00000097          	auipc	ra,0x0
    80003d8e:	c44080e7          	jalr	-956(ra) # 800039ce <writei>
    80003d92:	1541                	addi	a0,a0,-16
    80003d94:	00a03533          	snez	a0,a0
    80003d98:	40a00533          	neg	a0,a0
}
    80003d9c:	70e2                	ld	ra,56(sp)
    80003d9e:	7442                	ld	s0,48(sp)
    80003da0:	74a2                	ld	s1,40(sp)
    80003da2:	7902                	ld	s2,32(sp)
    80003da4:	69e2                	ld	s3,24(sp)
    80003da6:	6a42                	ld	s4,16(sp)
    80003da8:	6121                	addi	sp,sp,64
    80003daa:	8082                	ret
    iput(ip);
    80003dac:	00000097          	auipc	ra,0x0
    80003db0:	a30080e7          	jalr	-1488(ra) # 800037dc <iput>
    return -1;
    80003db4:	557d                	li	a0,-1
    80003db6:	b7dd                	j	80003d9c <dirlink+0x86>
      panic("dirlink read");
    80003db8:	00005517          	auipc	a0,0x5
    80003dbc:	86050513          	addi	a0,a0,-1952 # 80008618 <syscalls+0x1c8>
    80003dc0:	ffffc097          	auipc	ra,0xffffc
    80003dc4:	77c080e7          	jalr	1916(ra) # 8000053c <panic>

0000000080003dc8 <namei>:

struct inode*
namei(char *path)
{
    80003dc8:	1101                	addi	sp,sp,-32
    80003dca:	ec06                	sd	ra,24(sp)
    80003dcc:	e822                	sd	s0,16(sp)
    80003dce:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003dd0:	fe040613          	addi	a2,s0,-32
    80003dd4:	4581                	li	a1,0
    80003dd6:	00000097          	auipc	ra,0x0
    80003dda:	de0080e7          	jalr	-544(ra) # 80003bb6 <namex>
}
    80003dde:	60e2                	ld	ra,24(sp)
    80003de0:	6442                	ld	s0,16(sp)
    80003de2:	6105                	addi	sp,sp,32
    80003de4:	8082                	ret

0000000080003de6 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003de6:	1141                	addi	sp,sp,-16
    80003de8:	e406                	sd	ra,8(sp)
    80003dea:	e022                	sd	s0,0(sp)
    80003dec:	0800                	addi	s0,sp,16
    80003dee:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003df0:	4585                	li	a1,1
    80003df2:	00000097          	auipc	ra,0x0
    80003df6:	dc4080e7          	jalr	-572(ra) # 80003bb6 <namex>
}
    80003dfa:	60a2                	ld	ra,8(sp)
    80003dfc:	6402                	ld	s0,0(sp)
    80003dfe:	0141                	addi	sp,sp,16
    80003e00:	8082                	ret

0000000080003e02 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80003e02:	1101                	addi	sp,sp,-32
    80003e04:	ec06                	sd	ra,24(sp)
    80003e06:	e822                	sd	s0,16(sp)
    80003e08:	e426                	sd	s1,8(sp)
    80003e0a:	e04a                	sd	s2,0(sp)
    80003e0c:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80003e0e:	0001d917          	auipc	s2,0x1d
    80003e12:	cf290913          	addi	s2,s2,-782 # 80020b00 <log>
    80003e16:	01892583          	lw	a1,24(s2)
    80003e1a:	02892503          	lw	a0,40(s2)
    80003e1e:	fffff097          	auipc	ra,0xfffff
    80003e22:	ff4080e7          	jalr	-12(ra) # 80002e12 <bread>
    80003e26:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    80003e28:	02c92603          	lw	a2,44(s2)
    80003e2c:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80003e2e:	00c05f63          	blez	a2,80003e4c <write_head+0x4a>
    80003e32:	0001d717          	auipc	a4,0x1d
    80003e36:	cfe70713          	addi	a4,a4,-770 # 80020b30 <log+0x30>
    80003e3a:	87aa                	mv	a5,a0
    80003e3c:	060a                	slli	a2,a2,0x2
    80003e3e:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    80003e40:	4314                	lw	a3,0(a4)
    80003e42:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    80003e44:	0711                	addi	a4,a4,4
    80003e46:	0791                	addi	a5,a5,4
    80003e48:	fec79ce3          	bne	a5,a2,80003e40 <write_head+0x3e>
  }
  bwrite(buf);
    80003e4c:	8526                	mv	a0,s1
    80003e4e:	fffff097          	auipc	ra,0xfffff
    80003e52:	0b6080e7          	jalr	182(ra) # 80002f04 <bwrite>
  brelse(buf);
    80003e56:	8526                	mv	a0,s1
    80003e58:	fffff097          	auipc	ra,0xfffff
    80003e5c:	0ea080e7          	jalr	234(ra) # 80002f42 <brelse>
}
    80003e60:	60e2                	ld	ra,24(sp)
    80003e62:	6442                	ld	s0,16(sp)
    80003e64:	64a2                	ld	s1,8(sp)
    80003e66:	6902                	ld	s2,0(sp)
    80003e68:	6105                	addi	sp,sp,32
    80003e6a:	8082                	ret

0000000080003e6c <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e6c:	0001d797          	auipc	a5,0x1d
    80003e70:	cc07a783          	lw	a5,-832(a5) # 80020b2c <log+0x2c>
    80003e74:	0af05d63          	blez	a5,80003f2e <install_trans+0xc2>
{
    80003e78:	7139                	addi	sp,sp,-64
    80003e7a:	fc06                	sd	ra,56(sp)
    80003e7c:	f822                	sd	s0,48(sp)
    80003e7e:	f426                	sd	s1,40(sp)
    80003e80:	f04a                	sd	s2,32(sp)
    80003e82:	ec4e                	sd	s3,24(sp)
    80003e84:	e852                	sd	s4,16(sp)
    80003e86:	e456                	sd	s5,8(sp)
    80003e88:	e05a                	sd	s6,0(sp)
    80003e8a:	0080                	addi	s0,sp,64
    80003e8c:	8b2a                	mv	s6,a0
    80003e8e:	0001da97          	auipc	s5,0x1d
    80003e92:	ca2a8a93          	addi	s5,s5,-862 # 80020b30 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003e96:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003e98:	0001d997          	auipc	s3,0x1d
    80003e9c:	c6898993          	addi	s3,s3,-920 # 80020b00 <log>
    80003ea0:	a00d                	j	80003ec2 <install_trans+0x56>
    brelse(lbuf);
    80003ea2:	854a                	mv	a0,s2
    80003ea4:	fffff097          	auipc	ra,0xfffff
    80003ea8:	09e080e7          	jalr	158(ra) # 80002f42 <brelse>
    brelse(dbuf);
    80003eac:	8526                	mv	a0,s1
    80003eae:	fffff097          	auipc	ra,0xfffff
    80003eb2:	094080e7          	jalr	148(ra) # 80002f42 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003eb6:	2a05                	addiw	s4,s4,1
    80003eb8:	0a91                	addi	s5,s5,4
    80003eba:	02c9a783          	lw	a5,44(s3)
    80003ebe:	04fa5e63          	bge	s4,a5,80003f1a <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003ec2:	0189a583          	lw	a1,24(s3)
    80003ec6:	014585bb          	addw	a1,a1,s4
    80003eca:	2585                	addiw	a1,a1,1
    80003ecc:	0289a503          	lw	a0,40(s3)
    80003ed0:	fffff097          	auipc	ra,0xfffff
    80003ed4:	f42080e7          	jalr	-190(ra) # 80002e12 <bread>
    80003ed8:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003eda:	000aa583          	lw	a1,0(s5)
    80003ede:	0289a503          	lw	a0,40(s3)
    80003ee2:	fffff097          	auipc	ra,0xfffff
    80003ee6:	f30080e7          	jalr	-208(ra) # 80002e12 <bread>
    80003eea:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003eec:	40000613          	li	a2,1024
    80003ef0:	05890593          	addi	a1,s2,88
    80003ef4:	05850513          	addi	a0,a0,88
    80003ef8:	ffffd097          	auipc	ra,0xffffd
    80003efc:	e32080e7          	jalr	-462(ra) # 80000d2a <memmove>
    bwrite(dbuf);  // write dst to disk
    80003f00:	8526                	mv	a0,s1
    80003f02:	fffff097          	auipc	ra,0xfffff
    80003f06:	002080e7          	jalr	2(ra) # 80002f04 <bwrite>
    if(recovering == 0)
    80003f0a:	f80b1ce3          	bnez	s6,80003ea2 <install_trans+0x36>
      bunpin(dbuf);
    80003f0e:	8526                	mv	a0,s1
    80003f10:	fffff097          	auipc	ra,0xfffff
    80003f14:	10a080e7          	jalr	266(ra) # 8000301a <bunpin>
    80003f18:	b769                	j	80003ea2 <install_trans+0x36>
}
    80003f1a:	70e2                	ld	ra,56(sp)
    80003f1c:	7442                	ld	s0,48(sp)
    80003f1e:	74a2                	ld	s1,40(sp)
    80003f20:	7902                	ld	s2,32(sp)
    80003f22:	69e2                	ld	s3,24(sp)
    80003f24:	6a42                	ld	s4,16(sp)
    80003f26:	6aa2                	ld	s5,8(sp)
    80003f28:	6b02                	ld	s6,0(sp)
    80003f2a:	6121                	addi	sp,sp,64
    80003f2c:	8082                	ret
    80003f2e:	8082                	ret

0000000080003f30 <initlog>:
{
    80003f30:	7179                	addi	sp,sp,-48
    80003f32:	f406                	sd	ra,40(sp)
    80003f34:	f022                	sd	s0,32(sp)
    80003f36:	ec26                	sd	s1,24(sp)
    80003f38:	e84a                	sd	s2,16(sp)
    80003f3a:	e44e                	sd	s3,8(sp)
    80003f3c:	1800                	addi	s0,sp,48
    80003f3e:	892a                	mv	s2,a0
    80003f40:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003f42:	0001d497          	auipc	s1,0x1d
    80003f46:	bbe48493          	addi	s1,s1,-1090 # 80020b00 <log>
    80003f4a:	00004597          	auipc	a1,0x4
    80003f4e:	6de58593          	addi	a1,a1,1758 # 80008628 <syscalls+0x1d8>
    80003f52:	8526                	mv	a0,s1
    80003f54:	ffffd097          	auipc	ra,0xffffd
    80003f58:	bee080e7          	jalr	-1042(ra) # 80000b42 <initlock>
  log.start = sb->logstart;
    80003f5c:	0149a583          	lw	a1,20(s3)
    80003f60:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003f62:	0109a783          	lw	a5,16(s3)
    80003f66:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003f68:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003f6c:	854a                	mv	a0,s2
    80003f6e:	fffff097          	auipc	ra,0xfffff
    80003f72:	ea4080e7          	jalr	-348(ra) # 80002e12 <bread>
  log.lh.n = lh->n;
    80003f76:	4d30                	lw	a2,88(a0)
    80003f78:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003f7a:	00c05f63          	blez	a2,80003f98 <initlog+0x68>
    80003f7e:	87aa                	mv	a5,a0
    80003f80:	0001d717          	auipc	a4,0x1d
    80003f84:	bb070713          	addi	a4,a4,-1104 # 80020b30 <log+0x30>
    80003f88:	060a                	slli	a2,a2,0x2
    80003f8a:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003f8c:	4ff4                	lw	a3,92(a5)
    80003f8e:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003f90:	0791                	addi	a5,a5,4
    80003f92:	0711                	addi	a4,a4,4
    80003f94:	fec79ce3          	bne	a5,a2,80003f8c <initlog+0x5c>
  brelse(buf);
    80003f98:	fffff097          	auipc	ra,0xfffff
    80003f9c:	faa080e7          	jalr	-86(ra) # 80002f42 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003fa0:	4505                	li	a0,1
    80003fa2:	00000097          	auipc	ra,0x0
    80003fa6:	eca080e7          	jalr	-310(ra) # 80003e6c <install_trans>
  log.lh.n = 0;
    80003faa:	0001d797          	auipc	a5,0x1d
    80003fae:	b807a123          	sw	zero,-1150(a5) # 80020b2c <log+0x2c>
  write_head(); // clear the log
    80003fb2:	00000097          	auipc	ra,0x0
    80003fb6:	e50080e7          	jalr	-432(ra) # 80003e02 <write_head>
}
    80003fba:	70a2                	ld	ra,40(sp)
    80003fbc:	7402                	ld	s0,32(sp)
    80003fbe:	64e2                	ld	s1,24(sp)
    80003fc0:	6942                	ld	s2,16(sp)
    80003fc2:	69a2                	ld	s3,8(sp)
    80003fc4:	6145                	addi	sp,sp,48
    80003fc6:	8082                	ret

0000000080003fc8 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003fc8:	1101                	addi	sp,sp,-32
    80003fca:	ec06                	sd	ra,24(sp)
    80003fcc:	e822                	sd	s0,16(sp)
    80003fce:	e426                	sd	s1,8(sp)
    80003fd0:	e04a                	sd	s2,0(sp)
    80003fd2:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003fd4:	0001d517          	auipc	a0,0x1d
    80003fd8:	b2c50513          	addi	a0,a0,-1236 # 80020b00 <log>
    80003fdc:	ffffd097          	auipc	ra,0xffffd
    80003fe0:	bf6080e7          	jalr	-1034(ra) # 80000bd2 <acquire>
  while(1){
    if(log.committing){
    80003fe4:	0001d497          	auipc	s1,0x1d
    80003fe8:	b1c48493          	addi	s1,s1,-1252 # 80020b00 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003fec:	4979                	li	s2,30
    80003fee:	a039                	j	80003ffc <begin_op+0x34>
      sleep(&log, &log.lock);
    80003ff0:	85a6                	mv	a1,s1
    80003ff2:	8526                	mv	a0,s1
    80003ff4:	ffffe097          	auipc	ra,0xffffe
    80003ff8:	05a080e7          	jalr	90(ra) # 8000204e <sleep>
    if(log.committing){
    80003ffc:	50dc                	lw	a5,36(s1)
    80003ffe:	fbed                	bnez	a5,80003ff0 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004000:	5098                	lw	a4,32(s1)
    80004002:	2705                	addiw	a4,a4,1
    80004004:	0027179b          	slliw	a5,a4,0x2
    80004008:	9fb9                	addw	a5,a5,a4
    8000400a:	0017979b          	slliw	a5,a5,0x1
    8000400e:	54d4                	lw	a3,44(s1)
    80004010:	9fb5                	addw	a5,a5,a3
    80004012:	00f95963          	bge	s2,a5,80004024 <begin_op+0x5c>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80004016:	85a6                	mv	a1,s1
    80004018:	8526                	mv	a0,s1
    8000401a:	ffffe097          	auipc	ra,0xffffe
    8000401e:	034080e7          	jalr	52(ra) # 8000204e <sleep>
    80004022:	bfe9                	j	80003ffc <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80004024:	0001d517          	auipc	a0,0x1d
    80004028:	adc50513          	addi	a0,a0,-1316 # 80020b00 <log>
    8000402c:	d118                	sw	a4,32(a0)
      release(&log.lock);
    8000402e:	ffffd097          	auipc	ra,0xffffd
    80004032:	c58080e7          	jalr	-936(ra) # 80000c86 <release>
      break;
    }
  }
}
    80004036:	60e2                	ld	ra,24(sp)
    80004038:	6442                	ld	s0,16(sp)
    8000403a:	64a2                	ld	s1,8(sp)
    8000403c:	6902                	ld	s2,0(sp)
    8000403e:	6105                	addi	sp,sp,32
    80004040:	8082                	ret

0000000080004042 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004042:	7139                	addi	sp,sp,-64
    80004044:	fc06                	sd	ra,56(sp)
    80004046:	f822                	sd	s0,48(sp)
    80004048:	f426                	sd	s1,40(sp)
    8000404a:	f04a                	sd	s2,32(sp)
    8000404c:	ec4e                	sd	s3,24(sp)
    8000404e:	e852                	sd	s4,16(sp)
    80004050:	e456                	sd	s5,8(sp)
    80004052:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80004054:	0001d497          	auipc	s1,0x1d
    80004058:	aac48493          	addi	s1,s1,-1364 # 80020b00 <log>
    8000405c:	8526                	mv	a0,s1
    8000405e:	ffffd097          	auipc	ra,0xffffd
    80004062:	b74080e7          	jalr	-1164(ra) # 80000bd2 <acquire>
  log.outstanding -= 1;
    80004066:	509c                	lw	a5,32(s1)
    80004068:	37fd                	addiw	a5,a5,-1
    8000406a:	0007891b          	sext.w	s2,a5
    8000406e:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004070:	50dc                	lw	a5,36(s1)
    80004072:	e7b9                	bnez	a5,800040c0 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    80004074:	04091e63          	bnez	s2,800040d0 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    80004078:	0001d497          	auipc	s1,0x1d
    8000407c:	a8848493          	addi	s1,s1,-1400 # 80020b00 <log>
    80004080:	4785                	li	a5,1
    80004082:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80004084:	8526                	mv	a0,s1
    80004086:	ffffd097          	auipc	ra,0xffffd
    8000408a:	c00080e7          	jalr	-1024(ra) # 80000c86 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    8000408e:	54dc                	lw	a5,44(s1)
    80004090:	06f04763          	bgtz	a5,800040fe <end_op+0xbc>
    acquire(&log.lock);
    80004094:	0001d497          	auipc	s1,0x1d
    80004098:	a6c48493          	addi	s1,s1,-1428 # 80020b00 <log>
    8000409c:	8526                	mv	a0,s1
    8000409e:	ffffd097          	auipc	ra,0xffffd
    800040a2:	b34080e7          	jalr	-1228(ra) # 80000bd2 <acquire>
    log.committing = 0;
    800040a6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800040aa:	8526                	mv	a0,s1
    800040ac:	ffffe097          	auipc	ra,0xffffe
    800040b0:	006080e7          	jalr	6(ra) # 800020b2 <wakeup>
    release(&log.lock);
    800040b4:	8526                	mv	a0,s1
    800040b6:	ffffd097          	auipc	ra,0xffffd
    800040ba:	bd0080e7          	jalr	-1072(ra) # 80000c86 <release>
}
    800040be:	a03d                	j	800040ec <end_op+0xaa>
    panic("log.committing");
    800040c0:	00004517          	auipc	a0,0x4
    800040c4:	57050513          	addi	a0,a0,1392 # 80008630 <syscalls+0x1e0>
    800040c8:	ffffc097          	auipc	ra,0xffffc
    800040cc:	474080e7          	jalr	1140(ra) # 8000053c <panic>
    wakeup(&log);
    800040d0:	0001d497          	auipc	s1,0x1d
    800040d4:	a3048493          	addi	s1,s1,-1488 # 80020b00 <log>
    800040d8:	8526                	mv	a0,s1
    800040da:	ffffe097          	auipc	ra,0xffffe
    800040de:	fd8080e7          	jalr	-40(ra) # 800020b2 <wakeup>
  release(&log.lock);
    800040e2:	8526                	mv	a0,s1
    800040e4:	ffffd097          	auipc	ra,0xffffd
    800040e8:	ba2080e7          	jalr	-1118(ra) # 80000c86 <release>
}
    800040ec:	70e2                	ld	ra,56(sp)
    800040ee:	7442                	ld	s0,48(sp)
    800040f0:	74a2                	ld	s1,40(sp)
    800040f2:	7902                	ld	s2,32(sp)
    800040f4:	69e2                	ld	s3,24(sp)
    800040f6:	6a42                	ld	s4,16(sp)
    800040f8:	6aa2                	ld	s5,8(sp)
    800040fa:	6121                	addi	sp,sp,64
    800040fc:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    800040fe:	0001da97          	auipc	s5,0x1d
    80004102:	a32a8a93          	addi	s5,s5,-1486 # 80020b30 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80004106:	0001da17          	auipc	s4,0x1d
    8000410a:	9faa0a13          	addi	s4,s4,-1542 # 80020b00 <log>
    8000410e:	018a2583          	lw	a1,24(s4)
    80004112:	012585bb          	addw	a1,a1,s2
    80004116:	2585                	addiw	a1,a1,1
    80004118:	028a2503          	lw	a0,40(s4)
    8000411c:	fffff097          	auipc	ra,0xfffff
    80004120:	cf6080e7          	jalr	-778(ra) # 80002e12 <bread>
    80004124:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80004126:	000aa583          	lw	a1,0(s5)
    8000412a:	028a2503          	lw	a0,40(s4)
    8000412e:	fffff097          	auipc	ra,0xfffff
    80004132:	ce4080e7          	jalr	-796(ra) # 80002e12 <bread>
    80004136:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80004138:	40000613          	li	a2,1024
    8000413c:	05850593          	addi	a1,a0,88
    80004140:	05848513          	addi	a0,s1,88
    80004144:	ffffd097          	auipc	ra,0xffffd
    80004148:	be6080e7          	jalr	-1050(ra) # 80000d2a <memmove>
    bwrite(to);  // write the log
    8000414c:	8526                	mv	a0,s1
    8000414e:	fffff097          	auipc	ra,0xfffff
    80004152:	db6080e7          	jalr	-586(ra) # 80002f04 <bwrite>
    brelse(from);
    80004156:	854e                	mv	a0,s3
    80004158:	fffff097          	auipc	ra,0xfffff
    8000415c:	dea080e7          	jalr	-534(ra) # 80002f42 <brelse>
    brelse(to);
    80004160:	8526                	mv	a0,s1
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	de0080e7          	jalr	-544(ra) # 80002f42 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000416a:	2905                	addiw	s2,s2,1
    8000416c:	0a91                	addi	s5,s5,4
    8000416e:	02ca2783          	lw	a5,44(s4)
    80004172:	f8f94ee3          	blt	s2,a5,8000410e <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80004176:	00000097          	auipc	ra,0x0
    8000417a:	c8c080e7          	jalr	-884(ra) # 80003e02 <write_head>
    install_trans(0); // Now install writes to home locations
    8000417e:	4501                	li	a0,0
    80004180:	00000097          	auipc	ra,0x0
    80004184:	cec080e7          	jalr	-788(ra) # 80003e6c <install_trans>
    log.lh.n = 0;
    80004188:	0001d797          	auipc	a5,0x1d
    8000418c:	9a07a223          	sw	zero,-1628(a5) # 80020b2c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80004190:	00000097          	auipc	ra,0x0
    80004194:	c72080e7          	jalr	-910(ra) # 80003e02 <write_head>
    80004198:	bdf5                	j	80004094 <end_op+0x52>

000000008000419a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000419a:	1101                	addi	sp,sp,-32
    8000419c:	ec06                	sd	ra,24(sp)
    8000419e:	e822                	sd	s0,16(sp)
    800041a0:	e426                	sd	s1,8(sp)
    800041a2:	e04a                	sd	s2,0(sp)
    800041a4:	1000                	addi	s0,sp,32
    800041a6:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800041a8:	0001d917          	auipc	s2,0x1d
    800041ac:	95890913          	addi	s2,s2,-1704 # 80020b00 <log>
    800041b0:	854a                	mv	a0,s2
    800041b2:	ffffd097          	auipc	ra,0xffffd
    800041b6:	a20080e7          	jalr	-1504(ra) # 80000bd2 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800041ba:	02c92603          	lw	a2,44(s2)
    800041be:	47f5                	li	a5,29
    800041c0:	06c7c563          	blt	a5,a2,8000422a <log_write+0x90>
    800041c4:	0001d797          	auipc	a5,0x1d
    800041c8:	9587a783          	lw	a5,-1704(a5) # 80020b1c <log+0x1c>
    800041cc:	37fd                	addiw	a5,a5,-1
    800041ce:	04f65e63          	bge	a2,a5,8000422a <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800041d2:	0001d797          	auipc	a5,0x1d
    800041d6:	94e7a783          	lw	a5,-1714(a5) # 80020b20 <log+0x20>
    800041da:	06f05063          	blez	a5,8000423a <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    800041de:	4781                	li	a5,0
    800041e0:	06c05563          	blez	a2,8000424a <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041e4:	44cc                	lw	a1,12(s1)
    800041e6:	0001d717          	auipc	a4,0x1d
    800041ea:	94a70713          	addi	a4,a4,-1718 # 80020b30 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    800041ee:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    800041f0:	4314                	lw	a3,0(a4)
    800041f2:	04b68c63          	beq	a3,a1,8000424a <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    800041f6:	2785                	addiw	a5,a5,1
    800041f8:	0711                	addi	a4,a4,4
    800041fa:	fef61be3          	bne	a2,a5,800041f0 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    800041fe:	0621                	addi	a2,a2,8
    80004200:	060a                	slli	a2,a2,0x2
    80004202:	0001d797          	auipc	a5,0x1d
    80004206:	8fe78793          	addi	a5,a5,-1794 # 80020b00 <log>
    8000420a:	97b2                	add	a5,a5,a2
    8000420c:	44d8                	lw	a4,12(s1)
    8000420e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004210:	8526                	mv	a0,s1
    80004212:	fffff097          	auipc	ra,0xfffff
    80004216:	dcc080e7          	jalr	-564(ra) # 80002fde <bpin>
    log.lh.n++;
    8000421a:	0001d717          	auipc	a4,0x1d
    8000421e:	8e670713          	addi	a4,a4,-1818 # 80020b00 <log>
    80004222:	575c                	lw	a5,44(a4)
    80004224:	2785                	addiw	a5,a5,1
    80004226:	d75c                	sw	a5,44(a4)
    80004228:	a82d                	j	80004262 <log_write+0xc8>
    panic("too big a transaction");
    8000422a:	00004517          	auipc	a0,0x4
    8000422e:	41650513          	addi	a0,a0,1046 # 80008640 <syscalls+0x1f0>
    80004232:	ffffc097          	auipc	ra,0xffffc
    80004236:	30a080e7          	jalr	778(ra) # 8000053c <panic>
    panic("log_write outside of trans");
    8000423a:	00004517          	auipc	a0,0x4
    8000423e:	41e50513          	addi	a0,a0,1054 # 80008658 <syscalls+0x208>
    80004242:	ffffc097          	auipc	ra,0xffffc
    80004246:	2fa080e7          	jalr	762(ra) # 8000053c <panic>
  log.lh.block[i] = b->blockno;
    8000424a:	00878693          	addi	a3,a5,8
    8000424e:	068a                	slli	a3,a3,0x2
    80004250:	0001d717          	auipc	a4,0x1d
    80004254:	8b070713          	addi	a4,a4,-1872 # 80020b00 <log>
    80004258:	9736                	add	a4,a4,a3
    8000425a:	44d4                	lw	a3,12(s1)
    8000425c:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    8000425e:	faf609e3          	beq	a2,a5,80004210 <log_write+0x76>
  }
  release(&log.lock);
    80004262:	0001d517          	auipc	a0,0x1d
    80004266:	89e50513          	addi	a0,a0,-1890 # 80020b00 <log>
    8000426a:	ffffd097          	auipc	ra,0xffffd
    8000426e:	a1c080e7          	jalr	-1508(ra) # 80000c86 <release>
}
    80004272:	60e2                	ld	ra,24(sp)
    80004274:	6442                	ld	s0,16(sp)
    80004276:	64a2                	ld	s1,8(sp)
    80004278:	6902                	ld	s2,0(sp)
    8000427a:	6105                	addi	sp,sp,32
    8000427c:	8082                	ret

000000008000427e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    8000427e:	1101                	addi	sp,sp,-32
    80004280:	ec06                	sd	ra,24(sp)
    80004282:	e822                	sd	s0,16(sp)
    80004284:	e426                	sd	s1,8(sp)
    80004286:	e04a                	sd	s2,0(sp)
    80004288:	1000                	addi	s0,sp,32
    8000428a:	84aa                	mv	s1,a0
    8000428c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    8000428e:	00004597          	auipc	a1,0x4
    80004292:	3ea58593          	addi	a1,a1,1002 # 80008678 <syscalls+0x228>
    80004296:	0521                	addi	a0,a0,8
    80004298:	ffffd097          	auipc	ra,0xffffd
    8000429c:	8aa080e7          	jalr	-1878(ra) # 80000b42 <initlock>
  lk->name = name;
    800042a0:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800042a4:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800042a8:	0204a423          	sw	zero,40(s1)
}
    800042ac:	60e2                	ld	ra,24(sp)
    800042ae:	6442                	ld	s0,16(sp)
    800042b0:	64a2                	ld	s1,8(sp)
    800042b2:	6902                	ld	s2,0(sp)
    800042b4:	6105                	addi	sp,sp,32
    800042b6:	8082                	ret

00000000800042b8 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800042b8:	1101                	addi	sp,sp,-32
    800042ba:	ec06                	sd	ra,24(sp)
    800042bc:	e822                	sd	s0,16(sp)
    800042be:	e426                	sd	s1,8(sp)
    800042c0:	e04a                	sd	s2,0(sp)
    800042c2:	1000                	addi	s0,sp,32
    800042c4:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800042c6:	00850913          	addi	s2,a0,8
    800042ca:	854a                	mv	a0,s2
    800042cc:	ffffd097          	auipc	ra,0xffffd
    800042d0:	906080e7          	jalr	-1786(ra) # 80000bd2 <acquire>
  while (lk->locked) {
    800042d4:	409c                	lw	a5,0(s1)
    800042d6:	cb89                	beqz	a5,800042e8 <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800042d8:	85ca                	mv	a1,s2
    800042da:	8526                	mv	a0,s1
    800042dc:	ffffe097          	auipc	ra,0xffffe
    800042e0:	d72080e7          	jalr	-654(ra) # 8000204e <sleep>
  while (lk->locked) {
    800042e4:	409c                	lw	a5,0(s1)
    800042e6:	fbed                	bnez	a5,800042d8 <acquiresleep+0x20>
  }
  lk->locked = 1;
    800042e8:	4785                	li	a5,1
    800042ea:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800042ec:	ffffd097          	auipc	ra,0xffffd
    800042f0:	6ba080e7          	jalr	1722(ra) # 800019a6 <myproc>
    800042f4:	591c                	lw	a5,48(a0)
    800042f6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800042f8:	854a                	mv	a0,s2
    800042fa:	ffffd097          	auipc	ra,0xffffd
    800042fe:	98c080e7          	jalr	-1652(ra) # 80000c86 <release>
}
    80004302:	60e2                	ld	ra,24(sp)
    80004304:	6442                	ld	s0,16(sp)
    80004306:	64a2                	ld	s1,8(sp)
    80004308:	6902                	ld	s2,0(sp)
    8000430a:	6105                	addi	sp,sp,32
    8000430c:	8082                	ret

000000008000430e <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    8000430e:	1101                	addi	sp,sp,-32
    80004310:	ec06                	sd	ra,24(sp)
    80004312:	e822                	sd	s0,16(sp)
    80004314:	e426                	sd	s1,8(sp)
    80004316:	e04a                	sd	s2,0(sp)
    80004318:	1000                	addi	s0,sp,32
    8000431a:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000431c:	00850913          	addi	s2,a0,8
    80004320:	854a                	mv	a0,s2
    80004322:	ffffd097          	auipc	ra,0xffffd
    80004326:	8b0080e7          	jalr	-1872(ra) # 80000bd2 <acquire>
  lk->locked = 0;
    8000432a:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    8000432e:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004332:	8526                	mv	a0,s1
    80004334:	ffffe097          	auipc	ra,0xffffe
    80004338:	d7e080e7          	jalr	-642(ra) # 800020b2 <wakeup>
  release(&lk->lk);
    8000433c:	854a                	mv	a0,s2
    8000433e:	ffffd097          	auipc	ra,0xffffd
    80004342:	948080e7          	jalr	-1720(ra) # 80000c86 <release>
}
    80004346:	60e2                	ld	ra,24(sp)
    80004348:	6442                	ld	s0,16(sp)
    8000434a:	64a2                	ld	s1,8(sp)
    8000434c:	6902                	ld	s2,0(sp)
    8000434e:	6105                	addi	sp,sp,32
    80004350:	8082                	ret

0000000080004352 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004352:	7179                	addi	sp,sp,-48
    80004354:	f406                	sd	ra,40(sp)
    80004356:	f022                	sd	s0,32(sp)
    80004358:	ec26                	sd	s1,24(sp)
    8000435a:	e84a                	sd	s2,16(sp)
    8000435c:	e44e                	sd	s3,8(sp)
    8000435e:	1800                	addi	s0,sp,48
    80004360:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004362:	00850913          	addi	s2,a0,8
    80004366:	854a                	mv	a0,s2
    80004368:	ffffd097          	auipc	ra,0xffffd
    8000436c:	86a080e7          	jalr	-1942(ra) # 80000bd2 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004370:	409c                	lw	a5,0(s1)
    80004372:	ef99                	bnez	a5,80004390 <holdingsleep+0x3e>
    80004374:	4481                	li	s1,0
  release(&lk->lk);
    80004376:	854a                	mv	a0,s2
    80004378:	ffffd097          	auipc	ra,0xffffd
    8000437c:	90e080e7          	jalr	-1778(ra) # 80000c86 <release>
  return r;
}
    80004380:	8526                	mv	a0,s1
    80004382:	70a2                	ld	ra,40(sp)
    80004384:	7402                	ld	s0,32(sp)
    80004386:	64e2                	ld	s1,24(sp)
    80004388:	6942                	ld	s2,16(sp)
    8000438a:	69a2                	ld	s3,8(sp)
    8000438c:	6145                	addi	sp,sp,48
    8000438e:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80004390:	0284a983          	lw	s3,40(s1)
    80004394:	ffffd097          	auipc	ra,0xffffd
    80004398:	612080e7          	jalr	1554(ra) # 800019a6 <myproc>
    8000439c:	5904                	lw	s1,48(a0)
    8000439e:	413484b3          	sub	s1,s1,s3
    800043a2:	0014b493          	seqz	s1,s1
    800043a6:	bfc1                	j	80004376 <holdingsleep+0x24>

00000000800043a8 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800043a8:	1141                	addi	sp,sp,-16
    800043aa:	e406                	sd	ra,8(sp)
    800043ac:	e022                	sd	s0,0(sp)
    800043ae:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800043b0:	00004597          	auipc	a1,0x4
    800043b4:	2d858593          	addi	a1,a1,728 # 80008688 <syscalls+0x238>
    800043b8:	0001d517          	auipc	a0,0x1d
    800043bc:	89050513          	addi	a0,a0,-1904 # 80020c48 <ftable>
    800043c0:	ffffc097          	auipc	ra,0xffffc
    800043c4:	782080e7          	jalr	1922(ra) # 80000b42 <initlock>
}
    800043c8:	60a2                	ld	ra,8(sp)
    800043ca:	6402                	ld	s0,0(sp)
    800043cc:	0141                	addi	sp,sp,16
    800043ce:	8082                	ret

00000000800043d0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800043d0:	1101                	addi	sp,sp,-32
    800043d2:	ec06                	sd	ra,24(sp)
    800043d4:	e822                	sd	s0,16(sp)
    800043d6:	e426                	sd	s1,8(sp)
    800043d8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800043da:	0001d517          	auipc	a0,0x1d
    800043de:	86e50513          	addi	a0,a0,-1938 # 80020c48 <ftable>
    800043e2:	ffffc097          	auipc	ra,0xffffc
    800043e6:	7f0080e7          	jalr	2032(ra) # 80000bd2 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043ea:	0001d497          	auipc	s1,0x1d
    800043ee:	87648493          	addi	s1,s1,-1930 # 80020c60 <ftable+0x18>
    800043f2:	0001e717          	auipc	a4,0x1e
    800043f6:	80e70713          	addi	a4,a4,-2034 # 80021c00 <disk>
    if(f->ref == 0){
    800043fa:	40dc                	lw	a5,4(s1)
    800043fc:	cf99                	beqz	a5,8000441a <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800043fe:	02848493          	addi	s1,s1,40
    80004402:	fee49ce3          	bne	s1,a4,800043fa <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80004406:	0001d517          	auipc	a0,0x1d
    8000440a:	84250513          	addi	a0,a0,-1982 # 80020c48 <ftable>
    8000440e:	ffffd097          	auipc	ra,0xffffd
    80004412:	878080e7          	jalr	-1928(ra) # 80000c86 <release>
  return 0;
    80004416:	4481                	li	s1,0
    80004418:	a819                	j	8000442e <filealloc+0x5e>
      f->ref = 1;
    8000441a:	4785                	li	a5,1
    8000441c:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    8000441e:	0001d517          	auipc	a0,0x1d
    80004422:	82a50513          	addi	a0,a0,-2006 # 80020c48 <ftable>
    80004426:	ffffd097          	auipc	ra,0xffffd
    8000442a:	860080e7          	jalr	-1952(ra) # 80000c86 <release>
}
    8000442e:	8526                	mv	a0,s1
    80004430:	60e2                	ld	ra,24(sp)
    80004432:	6442                	ld	s0,16(sp)
    80004434:	64a2                	ld	s1,8(sp)
    80004436:	6105                	addi	sp,sp,32
    80004438:	8082                	ret

000000008000443a <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    8000443a:	1101                	addi	sp,sp,-32
    8000443c:	ec06                	sd	ra,24(sp)
    8000443e:	e822                	sd	s0,16(sp)
    80004440:	e426                	sd	s1,8(sp)
    80004442:	1000                	addi	s0,sp,32
    80004444:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80004446:	0001d517          	auipc	a0,0x1d
    8000444a:	80250513          	addi	a0,a0,-2046 # 80020c48 <ftable>
    8000444e:	ffffc097          	auipc	ra,0xffffc
    80004452:	784080e7          	jalr	1924(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    80004456:	40dc                	lw	a5,4(s1)
    80004458:	02f05263          	blez	a5,8000447c <filedup+0x42>
    panic("filedup");
  f->ref++;
    8000445c:	2785                	addiw	a5,a5,1
    8000445e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004460:	0001c517          	auipc	a0,0x1c
    80004464:	7e850513          	addi	a0,a0,2024 # 80020c48 <ftable>
    80004468:	ffffd097          	auipc	ra,0xffffd
    8000446c:	81e080e7          	jalr	-2018(ra) # 80000c86 <release>
  return f;
}
    80004470:	8526                	mv	a0,s1
    80004472:	60e2                	ld	ra,24(sp)
    80004474:	6442                	ld	s0,16(sp)
    80004476:	64a2                	ld	s1,8(sp)
    80004478:	6105                	addi	sp,sp,32
    8000447a:	8082                	ret
    panic("filedup");
    8000447c:	00004517          	auipc	a0,0x4
    80004480:	21450513          	addi	a0,a0,532 # 80008690 <syscalls+0x240>
    80004484:	ffffc097          	auipc	ra,0xffffc
    80004488:	0b8080e7          	jalr	184(ra) # 8000053c <panic>

000000008000448c <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    8000448c:	7139                	addi	sp,sp,-64
    8000448e:	fc06                	sd	ra,56(sp)
    80004490:	f822                	sd	s0,48(sp)
    80004492:	f426                	sd	s1,40(sp)
    80004494:	f04a                	sd	s2,32(sp)
    80004496:	ec4e                	sd	s3,24(sp)
    80004498:	e852                	sd	s4,16(sp)
    8000449a:	e456                	sd	s5,8(sp)
    8000449c:	0080                	addi	s0,sp,64
    8000449e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800044a0:	0001c517          	auipc	a0,0x1c
    800044a4:	7a850513          	addi	a0,a0,1960 # 80020c48 <ftable>
    800044a8:	ffffc097          	auipc	ra,0xffffc
    800044ac:	72a080e7          	jalr	1834(ra) # 80000bd2 <acquire>
  if(f->ref < 1)
    800044b0:	40dc                	lw	a5,4(s1)
    800044b2:	06f05163          	blez	a5,80004514 <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800044b6:	37fd                	addiw	a5,a5,-1
    800044b8:	0007871b          	sext.w	a4,a5
    800044bc:	c0dc                	sw	a5,4(s1)
    800044be:	06e04363          	bgtz	a4,80004524 <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800044c2:	0004a903          	lw	s2,0(s1)
    800044c6:	0094ca83          	lbu	s5,9(s1)
    800044ca:	0104ba03          	ld	s4,16(s1)
    800044ce:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800044d2:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800044d6:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    800044da:	0001c517          	auipc	a0,0x1c
    800044de:	76e50513          	addi	a0,a0,1902 # 80020c48 <ftable>
    800044e2:	ffffc097          	auipc	ra,0xffffc
    800044e6:	7a4080e7          	jalr	1956(ra) # 80000c86 <release>

  if(ff.type == FD_PIPE){
    800044ea:	4785                	li	a5,1
    800044ec:	04f90d63          	beq	s2,a5,80004546 <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    800044f0:	3979                	addiw	s2,s2,-2
    800044f2:	4785                	li	a5,1
    800044f4:	0527e063          	bltu	a5,s2,80004534 <fileclose+0xa8>
    begin_op();
    800044f8:	00000097          	auipc	ra,0x0
    800044fc:	ad0080e7          	jalr	-1328(ra) # 80003fc8 <begin_op>
    iput(ff.ip);
    80004500:	854e                	mv	a0,s3
    80004502:	fffff097          	auipc	ra,0xfffff
    80004506:	2da080e7          	jalr	730(ra) # 800037dc <iput>
    end_op();
    8000450a:	00000097          	auipc	ra,0x0
    8000450e:	b38080e7          	jalr	-1224(ra) # 80004042 <end_op>
    80004512:	a00d                	j	80004534 <fileclose+0xa8>
    panic("fileclose");
    80004514:	00004517          	auipc	a0,0x4
    80004518:	18450513          	addi	a0,a0,388 # 80008698 <syscalls+0x248>
    8000451c:	ffffc097          	auipc	ra,0xffffc
    80004520:	020080e7          	jalr	32(ra) # 8000053c <panic>
    release(&ftable.lock);
    80004524:	0001c517          	auipc	a0,0x1c
    80004528:	72450513          	addi	a0,a0,1828 # 80020c48 <ftable>
    8000452c:	ffffc097          	auipc	ra,0xffffc
    80004530:	75a080e7          	jalr	1882(ra) # 80000c86 <release>
  }
}
    80004534:	70e2                	ld	ra,56(sp)
    80004536:	7442                	ld	s0,48(sp)
    80004538:	74a2                	ld	s1,40(sp)
    8000453a:	7902                	ld	s2,32(sp)
    8000453c:	69e2                	ld	s3,24(sp)
    8000453e:	6a42                	ld	s4,16(sp)
    80004540:	6aa2                	ld	s5,8(sp)
    80004542:	6121                	addi	sp,sp,64
    80004544:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80004546:	85d6                	mv	a1,s5
    80004548:	8552                	mv	a0,s4
    8000454a:	00000097          	auipc	ra,0x0
    8000454e:	348080e7          	jalr	840(ra) # 80004892 <pipeclose>
    80004552:	b7cd                	j	80004534 <fileclose+0xa8>

0000000080004554 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004554:	715d                	addi	sp,sp,-80
    80004556:	e486                	sd	ra,72(sp)
    80004558:	e0a2                	sd	s0,64(sp)
    8000455a:	fc26                	sd	s1,56(sp)
    8000455c:	f84a                	sd	s2,48(sp)
    8000455e:	f44e                	sd	s3,40(sp)
    80004560:	0880                	addi	s0,sp,80
    80004562:	84aa                	mv	s1,a0
    80004564:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004566:	ffffd097          	auipc	ra,0xffffd
    8000456a:	440080e7          	jalr	1088(ra) # 800019a6 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000456e:	409c                	lw	a5,0(s1)
    80004570:	37f9                	addiw	a5,a5,-2
    80004572:	4705                	li	a4,1
    80004574:	04f76763          	bltu	a4,a5,800045c2 <filestat+0x6e>
    80004578:	892a                	mv	s2,a0
    ilock(f->ip);
    8000457a:	6c88                	ld	a0,24(s1)
    8000457c:	fffff097          	auipc	ra,0xfffff
    80004580:	0a6080e7          	jalr	166(ra) # 80003622 <ilock>
    stati(f->ip, &st);
    80004584:	fb840593          	addi	a1,s0,-72
    80004588:	6c88                	ld	a0,24(s1)
    8000458a:	fffff097          	auipc	ra,0xfffff
    8000458e:	322080e7          	jalr	802(ra) # 800038ac <stati>
    iunlock(f->ip);
    80004592:	6c88                	ld	a0,24(s1)
    80004594:	fffff097          	auipc	ra,0xfffff
    80004598:	150080e7          	jalr	336(ra) # 800036e4 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000459c:	46e1                	li	a3,24
    8000459e:	fb840613          	addi	a2,s0,-72
    800045a2:	85ce                	mv	a1,s3
    800045a4:	05093503          	ld	a0,80(s2)
    800045a8:	ffffd097          	auipc	ra,0xffffd
    800045ac:	0be080e7          	jalr	190(ra) # 80001666 <copyout>
    800045b0:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800045b4:	60a6                	ld	ra,72(sp)
    800045b6:	6406                	ld	s0,64(sp)
    800045b8:	74e2                	ld	s1,56(sp)
    800045ba:	7942                	ld	s2,48(sp)
    800045bc:	79a2                	ld	s3,40(sp)
    800045be:	6161                	addi	sp,sp,80
    800045c0:	8082                	ret
  return -1;
    800045c2:	557d                	li	a0,-1
    800045c4:	bfc5                	j	800045b4 <filestat+0x60>

00000000800045c6 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800045c6:	7179                	addi	sp,sp,-48
    800045c8:	f406                	sd	ra,40(sp)
    800045ca:	f022                	sd	s0,32(sp)
    800045cc:	ec26                	sd	s1,24(sp)
    800045ce:	e84a                	sd	s2,16(sp)
    800045d0:	e44e                	sd	s3,8(sp)
    800045d2:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800045d4:	00854783          	lbu	a5,8(a0)
    800045d8:	c3d5                	beqz	a5,8000467c <fileread+0xb6>
    800045da:	84aa                	mv	s1,a0
    800045dc:	89ae                	mv	s3,a1
    800045de:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    800045e0:	411c                	lw	a5,0(a0)
    800045e2:	4705                	li	a4,1
    800045e4:	04e78963          	beq	a5,a4,80004636 <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800045e8:	470d                	li	a4,3
    800045ea:	04e78d63          	beq	a5,a4,80004644 <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    800045ee:	4709                	li	a4,2
    800045f0:	06e79e63          	bne	a5,a4,8000466c <fileread+0xa6>
    ilock(f->ip);
    800045f4:	6d08                	ld	a0,24(a0)
    800045f6:	fffff097          	auipc	ra,0xfffff
    800045fa:	02c080e7          	jalr	44(ra) # 80003622 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    800045fe:	874a                	mv	a4,s2
    80004600:	5094                	lw	a3,32(s1)
    80004602:	864e                	mv	a2,s3
    80004604:	4585                	li	a1,1
    80004606:	6c88                	ld	a0,24(s1)
    80004608:	fffff097          	auipc	ra,0xfffff
    8000460c:	2ce080e7          	jalr	718(ra) # 800038d6 <readi>
    80004610:	892a                	mv	s2,a0
    80004612:	00a05563          	blez	a0,8000461c <fileread+0x56>
      f->off += r;
    80004616:	509c                	lw	a5,32(s1)
    80004618:	9fa9                	addw	a5,a5,a0
    8000461a:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    8000461c:	6c88                	ld	a0,24(s1)
    8000461e:	fffff097          	auipc	ra,0xfffff
    80004622:	0c6080e7          	jalr	198(ra) # 800036e4 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    80004626:	854a                	mv	a0,s2
    80004628:	70a2                	ld	ra,40(sp)
    8000462a:	7402                	ld	s0,32(sp)
    8000462c:	64e2                	ld	s1,24(sp)
    8000462e:	6942                	ld	s2,16(sp)
    80004630:	69a2                	ld	s3,8(sp)
    80004632:	6145                	addi	sp,sp,48
    80004634:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80004636:	6908                	ld	a0,16(a0)
    80004638:	00000097          	auipc	ra,0x0
    8000463c:	3c2080e7          	jalr	962(ra) # 800049fa <piperead>
    80004640:	892a                	mv	s2,a0
    80004642:	b7d5                	j	80004626 <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80004644:	02451783          	lh	a5,36(a0)
    80004648:	03079693          	slli	a3,a5,0x30
    8000464c:	92c1                	srli	a3,a3,0x30
    8000464e:	4725                	li	a4,9
    80004650:	02d76863          	bltu	a4,a3,80004680 <fileread+0xba>
    80004654:	0792                	slli	a5,a5,0x4
    80004656:	0001c717          	auipc	a4,0x1c
    8000465a:	55270713          	addi	a4,a4,1362 # 80020ba8 <devsw>
    8000465e:	97ba                	add	a5,a5,a4
    80004660:	639c                	ld	a5,0(a5)
    80004662:	c38d                	beqz	a5,80004684 <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    80004664:	4505                	li	a0,1
    80004666:	9782                	jalr	a5
    80004668:	892a                	mv	s2,a0
    8000466a:	bf75                	j	80004626 <fileread+0x60>
    panic("fileread");
    8000466c:	00004517          	auipc	a0,0x4
    80004670:	03c50513          	addi	a0,a0,60 # 800086a8 <syscalls+0x258>
    80004674:	ffffc097          	auipc	ra,0xffffc
    80004678:	ec8080e7          	jalr	-312(ra) # 8000053c <panic>
    return -1;
    8000467c:	597d                	li	s2,-1
    8000467e:	b765                	j	80004626 <fileread+0x60>
      return -1;
    80004680:	597d                	li	s2,-1
    80004682:	b755                	j	80004626 <fileread+0x60>
    80004684:	597d                	li	s2,-1
    80004686:	b745                	j	80004626 <fileread+0x60>

0000000080004688 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004688:	00954783          	lbu	a5,9(a0)
    8000468c:	10078e63          	beqz	a5,800047a8 <filewrite+0x120>
{
    80004690:	715d                	addi	sp,sp,-80
    80004692:	e486                	sd	ra,72(sp)
    80004694:	e0a2                	sd	s0,64(sp)
    80004696:	fc26                	sd	s1,56(sp)
    80004698:	f84a                	sd	s2,48(sp)
    8000469a:	f44e                	sd	s3,40(sp)
    8000469c:	f052                	sd	s4,32(sp)
    8000469e:	ec56                	sd	s5,24(sp)
    800046a0:	e85a                	sd	s6,16(sp)
    800046a2:	e45e                	sd	s7,8(sp)
    800046a4:	e062                	sd	s8,0(sp)
    800046a6:	0880                	addi	s0,sp,80
    800046a8:	892a                	mv	s2,a0
    800046aa:	8b2e                	mv	s6,a1
    800046ac:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800046ae:	411c                	lw	a5,0(a0)
    800046b0:	4705                	li	a4,1
    800046b2:	02e78263          	beq	a5,a4,800046d6 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800046b6:	470d                	li	a4,3
    800046b8:	02e78563          	beq	a5,a4,800046e2 <filewrite+0x5a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800046bc:	4709                	li	a4,2
    800046be:	0ce79d63          	bne	a5,a4,80004798 <filewrite+0x110>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800046c2:	0ac05b63          	blez	a2,80004778 <filewrite+0xf0>
    int i = 0;
    800046c6:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    800046c8:	6b85                	lui	s7,0x1
    800046ca:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800046ce:	6c05                	lui	s8,0x1
    800046d0:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800046d4:	a851                	j	80004768 <filewrite+0xe0>
    ret = pipewrite(f->pipe, addr, n);
    800046d6:	6908                	ld	a0,16(a0)
    800046d8:	00000097          	auipc	ra,0x0
    800046dc:	22a080e7          	jalr	554(ra) # 80004902 <pipewrite>
    800046e0:	a045                	j	80004780 <filewrite+0xf8>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    800046e2:	02451783          	lh	a5,36(a0)
    800046e6:	03079693          	slli	a3,a5,0x30
    800046ea:	92c1                	srli	a3,a3,0x30
    800046ec:	4725                	li	a4,9
    800046ee:	0ad76f63          	bltu	a4,a3,800047ac <filewrite+0x124>
    800046f2:	0792                	slli	a5,a5,0x4
    800046f4:	0001c717          	auipc	a4,0x1c
    800046f8:	4b470713          	addi	a4,a4,1204 # 80020ba8 <devsw>
    800046fc:	97ba                	add	a5,a5,a4
    800046fe:	679c                	ld	a5,8(a5)
    80004700:	cbc5                	beqz	a5,800047b0 <filewrite+0x128>
    ret = devsw[f->major].write(1, addr, n);
    80004702:	4505                	li	a0,1
    80004704:	9782                	jalr	a5
    80004706:	a8ad                	j	80004780 <filewrite+0xf8>
      if(n1 > max)
    80004708:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    8000470c:	00000097          	auipc	ra,0x0
    80004710:	8bc080e7          	jalr	-1860(ra) # 80003fc8 <begin_op>
      ilock(f->ip);
    80004714:	01893503          	ld	a0,24(s2)
    80004718:	fffff097          	auipc	ra,0xfffff
    8000471c:	f0a080e7          	jalr	-246(ra) # 80003622 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004720:	8756                	mv	a4,s5
    80004722:	02092683          	lw	a3,32(s2)
    80004726:	01698633          	add	a2,s3,s6
    8000472a:	4585                	li	a1,1
    8000472c:	01893503          	ld	a0,24(s2)
    80004730:	fffff097          	auipc	ra,0xfffff
    80004734:	29e080e7          	jalr	670(ra) # 800039ce <writei>
    80004738:	84aa                	mv	s1,a0
    8000473a:	00a05763          	blez	a0,80004748 <filewrite+0xc0>
        f->off += r;
    8000473e:	02092783          	lw	a5,32(s2)
    80004742:	9fa9                	addw	a5,a5,a0
    80004744:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004748:	01893503          	ld	a0,24(s2)
    8000474c:	fffff097          	auipc	ra,0xfffff
    80004750:	f98080e7          	jalr	-104(ra) # 800036e4 <iunlock>
      end_op();
    80004754:	00000097          	auipc	ra,0x0
    80004758:	8ee080e7          	jalr	-1810(ra) # 80004042 <end_op>

      if(r != n1){
    8000475c:	009a9f63          	bne	s5,s1,8000477a <filewrite+0xf2>
        // error from writei
        break;
      }
      i += r;
    80004760:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004764:	0149db63          	bge	s3,s4,8000477a <filewrite+0xf2>
      int n1 = n - i;
    80004768:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    8000476c:	0004879b          	sext.w	a5,s1
    80004770:	f8fbdce3          	bge	s7,a5,80004708 <filewrite+0x80>
    80004774:	84e2                	mv	s1,s8
    80004776:	bf49                	j	80004708 <filewrite+0x80>
    int i = 0;
    80004778:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    8000477a:	033a1d63          	bne	s4,s3,800047b4 <filewrite+0x12c>
    8000477e:	8552                	mv	a0,s4
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004780:	60a6                	ld	ra,72(sp)
    80004782:	6406                	ld	s0,64(sp)
    80004784:	74e2                	ld	s1,56(sp)
    80004786:	7942                	ld	s2,48(sp)
    80004788:	79a2                	ld	s3,40(sp)
    8000478a:	7a02                	ld	s4,32(sp)
    8000478c:	6ae2                	ld	s5,24(sp)
    8000478e:	6b42                	ld	s6,16(sp)
    80004790:	6ba2                	ld	s7,8(sp)
    80004792:	6c02                	ld	s8,0(sp)
    80004794:	6161                	addi	sp,sp,80
    80004796:	8082                	ret
    panic("filewrite");
    80004798:	00004517          	auipc	a0,0x4
    8000479c:	f2050513          	addi	a0,a0,-224 # 800086b8 <syscalls+0x268>
    800047a0:	ffffc097          	auipc	ra,0xffffc
    800047a4:	d9c080e7          	jalr	-612(ra) # 8000053c <panic>
    return -1;
    800047a8:	557d                	li	a0,-1
}
    800047aa:	8082                	ret
      return -1;
    800047ac:	557d                	li	a0,-1
    800047ae:	bfc9                	j	80004780 <filewrite+0xf8>
    800047b0:	557d                	li	a0,-1
    800047b2:	b7f9                	j	80004780 <filewrite+0xf8>
    ret = (i == n ? n : -1);
    800047b4:	557d                	li	a0,-1
    800047b6:	b7e9                	j	80004780 <filewrite+0xf8>

00000000800047b8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    800047b8:	7179                	addi	sp,sp,-48
    800047ba:	f406                	sd	ra,40(sp)
    800047bc:	f022                	sd	s0,32(sp)
    800047be:	ec26                	sd	s1,24(sp)
    800047c0:	e84a                	sd	s2,16(sp)
    800047c2:	e44e                	sd	s3,8(sp)
    800047c4:	e052                	sd	s4,0(sp)
    800047c6:	1800                	addi	s0,sp,48
    800047c8:	84aa                	mv	s1,a0
    800047ca:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    800047cc:	0005b023          	sd	zero,0(a1)
    800047d0:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    800047d4:	00000097          	auipc	ra,0x0
    800047d8:	bfc080e7          	jalr	-1028(ra) # 800043d0 <filealloc>
    800047dc:	e088                	sd	a0,0(s1)
    800047de:	c551                	beqz	a0,8000486a <pipealloc+0xb2>
    800047e0:	00000097          	auipc	ra,0x0
    800047e4:	bf0080e7          	jalr	-1040(ra) # 800043d0 <filealloc>
    800047e8:	00aa3023          	sd	a0,0(s4)
    800047ec:	c92d                	beqz	a0,8000485e <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    800047ee:	ffffc097          	auipc	ra,0xffffc
    800047f2:	2f4080e7          	jalr	756(ra) # 80000ae2 <kalloc>
    800047f6:	892a                	mv	s2,a0
    800047f8:	c125                	beqz	a0,80004858 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    800047fa:	4985                	li	s3,1
    800047fc:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004800:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004804:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004808:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    8000480c:	00004597          	auipc	a1,0x4
    80004810:	ebc58593          	addi	a1,a1,-324 # 800086c8 <syscalls+0x278>
    80004814:	ffffc097          	auipc	ra,0xffffc
    80004818:	32e080e7          	jalr	814(ra) # 80000b42 <initlock>
  (*f0)->type = FD_PIPE;
    8000481c:	609c                	ld	a5,0(s1)
    8000481e:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004822:	609c                	ld	a5,0(s1)
    80004824:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004828:	609c                	ld	a5,0(s1)
    8000482a:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    8000482e:	609c                	ld	a5,0(s1)
    80004830:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004834:	000a3783          	ld	a5,0(s4)
    80004838:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    8000483c:	000a3783          	ld	a5,0(s4)
    80004840:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004844:	000a3783          	ld	a5,0(s4)
    80004848:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    8000484c:	000a3783          	ld	a5,0(s4)
    80004850:	0127b823          	sd	s2,16(a5)
  return 0;
    80004854:	4501                	li	a0,0
    80004856:	a025                	j	8000487e <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004858:	6088                	ld	a0,0(s1)
    8000485a:	e501                	bnez	a0,80004862 <pipealloc+0xaa>
    8000485c:	a039                	j	8000486a <pipealloc+0xb2>
    8000485e:	6088                	ld	a0,0(s1)
    80004860:	c51d                	beqz	a0,8000488e <pipealloc+0xd6>
    fileclose(*f0);
    80004862:	00000097          	auipc	ra,0x0
    80004866:	c2a080e7          	jalr	-982(ra) # 8000448c <fileclose>
  if(*f1)
    8000486a:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    8000486e:	557d                	li	a0,-1
  if(*f1)
    80004870:	c799                	beqz	a5,8000487e <pipealloc+0xc6>
    fileclose(*f1);
    80004872:	853e                	mv	a0,a5
    80004874:	00000097          	auipc	ra,0x0
    80004878:	c18080e7          	jalr	-1000(ra) # 8000448c <fileclose>
  return -1;
    8000487c:	557d                	li	a0,-1
}
    8000487e:	70a2                	ld	ra,40(sp)
    80004880:	7402                	ld	s0,32(sp)
    80004882:	64e2                	ld	s1,24(sp)
    80004884:	6942                	ld	s2,16(sp)
    80004886:	69a2                	ld	s3,8(sp)
    80004888:	6a02                	ld	s4,0(sp)
    8000488a:	6145                	addi	sp,sp,48
    8000488c:	8082                	ret
  return -1;
    8000488e:	557d                	li	a0,-1
    80004890:	b7fd                	j	8000487e <pipealloc+0xc6>

0000000080004892 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004892:	1101                	addi	sp,sp,-32
    80004894:	ec06                	sd	ra,24(sp)
    80004896:	e822                	sd	s0,16(sp)
    80004898:	e426                	sd	s1,8(sp)
    8000489a:	e04a                	sd	s2,0(sp)
    8000489c:	1000                	addi	s0,sp,32
    8000489e:	84aa                	mv	s1,a0
    800048a0:	892e                	mv	s2,a1
  acquire(&pi->lock);
    800048a2:	ffffc097          	auipc	ra,0xffffc
    800048a6:	330080e7          	jalr	816(ra) # 80000bd2 <acquire>
  if(writable){
    800048aa:	02090d63          	beqz	s2,800048e4 <pipeclose+0x52>
    pi->writeopen = 0;
    800048ae:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    800048b2:	21848513          	addi	a0,s1,536
    800048b6:	ffffd097          	auipc	ra,0xffffd
    800048ba:	7fc080e7          	jalr	2044(ra) # 800020b2 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    800048be:	2204b783          	ld	a5,544(s1)
    800048c2:	eb95                	bnez	a5,800048f6 <pipeclose+0x64>
    release(&pi->lock);
    800048c4:	8526                	mv	a0,s1
    800048c6:	ffffc097          	auipc	ra,0xffffc
    800048ca:	3c0080e7          	jalr	960(ra) # 80000c86 <release>
    kfree((char*)pi);
    800048ce:	8526                	mv	a0,s1
    800048d0:	ffffc097          	auipc	ra,0xffffc
    800048d4:	114080e7          	jalr	276(ra) # 800009e4 <kfree>
  } else
    release(&pi->lock);
}
    800048d8:	60e2                	ld	ra,24(sp)
    800048da:	6442                	ld	s0,16(sp)
    800048dc:	64a2                	ld	s1,8(sp)
    800048de:	6902                	ld	s2,0(sp)
    800048e0:	6105                	addi	sp,sp,32
    800048e2:	8082                	ret
    pi->readopen = 0;
    800048e4:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    800048e8:	21c48513          	addi	a0,s1,540
    800048ec:	ffffd097          	auipc	ra,0xffffd
    800048f0:	7c6080e7          	jalr	1990(ra) # 800020b2 <wakeup>
    800048f4:	b7e9                	j	800048be <pipeclose+0x2c>
    release(&pi->lock);
    800048f6:	8526                	mv	a0,s1
    800048f8:	ffffc097          	auipc	ra,0xffffc
    800048fc:	38e080e7          	jalr	910(ra) # 80000c86 <release>
}
    80004900:	bfe1                	j	800048d8 <pipeclose+0x46>

0000000080004902 <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004902:	711d                	addi	sp,sp,-96
    80004904:	ec86                	sd	ra,88(sp)
    80004906:	e8a2                	sd	s0,80(sp)
    80004908:	e4a6                	sd	s1,72(sp)
    8000490a:	e0ca                	sd	s2,64(sp)
    8000490c:	fc4e                	sd	s3,56(sp)
    8000490e:	f852                	sd	s4,48(sp)
    80004910:	f456                	sd	s5,40(sp)
    80004912:	f05a                	sd	s6,32(sp)
    80004914:	ec5e                	sd	s7,24(sp)
    80004916:	e862                	sd	s8,16(sp)
    80004918:	1080                	addi	s0,sp,96
    8000491a:	84aa                	mv	s1,a0
    8000491c:	8aae                	mv	s5,a1
    8000491e:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004920:	ffffd097          	auipc	ra,0xffffd
    80004924:	086080e7          	jalr	134(ra) # 800019a6 <myproc>
    80004928:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000492a:	8526                	mv	a0,s1
    8000492c:	ffffc097          	auipc	ra,0xffffc
    80004930:	2a6080e7          	jalr	678(ra) # 80000bd2 <acquire>
  while(i < n){
    80004934:	0b405663          	blez	s4,800049e0 <pipewrite+0xde>
  int i = 0;
    80004938:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000493a:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    8000493c:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004940:	21c48b93          	addi	s7,s1,540
    80004944:	a089                	j	80004986 <pipewrite+0x84>
      release(&pi->lock);
    80004946:	8526                	mv	a0,s1
    80004948:	ffffc097          	auipc	ra,0xffffc
    8000494c:	33e080e7          	jalr	830(ra) # 80000c86 <release>
      return -1;
    80004950:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004952:	854a                	mv	a0,s2
    80004954:	60e6                	ld	ra,88(sp)
    80004956:	6446                	ld	s0,80(sp)
    80004958:	64a6                	ld	s1,72(sp)
    8000495a:	6906                	ld	s2,64(sp)
    8000495c:	79e2                	ld	s3,56(sp)
    8000495e:	7a42                	ld	s4,48(sp)
    80004960:	7aa2                	ld	s5,40(sp)
    80004962:	7b02                	ld	s6,32(sp)
    80004964:	6be2                	ld	s7,24(sp)
    80004966:	6c42                	ld	s8,16(sp)
    80004968:	6125                	addi	sp,sp,96
    8000496a:	8082                	ret
      wakeup(&pi->nread);
    8000496c:	8562                	mv	a0,s8
    8000496e:	ffffd097          	auipc	ra,0xffffd
    80004972:	744080e7          	jalr	1860(ra) # 800020b2 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004976:	85a6                	mv	a1,s1
    80004978:	855e                	mv	a0,s7
    8000497a:	ffffd097          	auipc	ra,0xffffd
    8000497e:	6d4080e7          	jalr	1748(ra) # 8000204e <sleep>
  while(i < n){
    80004982:	07495063          	bge	s2,s4,800049e2 <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004986:	2204a783          	lw	a5,544(s1)
    8000498a:	dfd5                	beqz	a5,80004946 <pipewrite+0x44>
    8000498c:	854e                	mv	a0,s3
    8000498e:	ffffe097          	auipc	ra,0xffffe
    80004992:	968080e7          	jalr	-1688(ra) # 800022f6 <killed>
    80004996:	f945                	bnez	a0,80004946 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004998:	2184a783          	lw	a5,536(s1)
    8000499c:	21c4a703          	lw	a4,540(s1)
    800049a0:	2007879b          	addiw	a5,a5,512
    800049a4:	fcf704e3          	beq	a4,a5,8000496c <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800049a8:	4685                	li	a3,1
    800049aa:	01590633          	add	a2,s2,s5
    800049ae:	faf40593          	addi	a1,s0,-81
    800049b2:	0509b503          	ld	a0,80(s3)
    800049b6:	ffffd097          	auipc	ra,0xffffd
    800049ba:	d3c080e7          	jalr	-708(ra) # 800016f2 <copyin>
    800049be:	03650263          	beq	a0,s6,800049e2 <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    800049c2:	21c4a783          	lw	a5,540(s1)
    800049c6:	0017871b          	addiw	a4,a5,1
    800049ca:	20e4ae23          	sw	a4,540(s1)
    800049ce:	1ff7f793          	andi	a5,a5,511
    800049d2:	97a6                	add	a5,a5,s1
    800049d4:	faf44703          	lbu	a4,-81(s0)
    800049d8:	00e78c23          	sb	a4,24(a5)
      i++;
    800049dc:	2905                	addiw	s2,s2,1
    800049de:	b755                	j	80004982 <pipewrite+0x80>
  int i = 0;
    800049e0:	4901                	li	s2,0
  wakeup(&pi->nread);
    800049e2:	21848513          	addi	a0,s1,536
    800049e6:	ffffd097          	auipc	ra,0xffffd
    800049ea:	6cc080e7          	jalr	1740(ra) # 800020b2 <wakeup>
  release(&pi->lock);
    800049ee:	8526                	mv	a0,s1
    800049f0:	ffffc097          	auipc	ra,0xffffc
    800049f4:	296080e7          	jalr	662(ra) # 80000c86 <release>
  return i;
    800049f8:	bfa9                	j	80004952 <pipewrite+0x50>

00000000800049fa <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    800049fa:	715d                	addi	sp,sp,-80
    800049fc:	e486                	sd	ra,72(sp)
    800049fe:	e0a2                	sd	s0,64(sp)
    80004a00:	fc26                	sd	s1,56(sp)
    80004a02:	f84a                	sd	s2,48(sp)
    80004a04:	f44e                	sd	s3,40(sp)
    80004a06:	f052                	sd	s4,32(sp)
    80004a08:	ec56                	sd	s5,24(sp)
    80004a0a:	e85a                	sd	s6,16(sp)
    80004a0c:	0880                	addi	s0,sp,80
    80004a0e:	84aa                	mv	s1,a0
    80004a10:	892e                	mv	s2,a1
    80004a12:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004a14:	ffffd097          	auipc	ra,0xffffd
    80004a18:	f92080e7          	jalr	-110(ra) # 800019a6 <myproc>
    80004a1c:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004a1e:	8526                	mv	a0,s1
    80004a20:	ffffc097          	auipc	ra,0xffffc
    80004a24:	1b2080e7          	jalr	434(ra) # 80000bd2 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a28:	2184a703          	lw	a4,536(s1)
    80004a2c:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a30:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a34:	02f71763          	bne	a4,a5,80004a62 <piperead+0x68>
    80004a38:	2244a783          	lw	a5,548(s1)
    80004a3c:	c39d                	beqz	a5,80004a62 <piperead+0x68>
    if(killed(pr)){
    80004a3e:	8552                	mv	a0,s4
    80004a40:	ffffe097          	auipc	ra,0xffffe
    80004a44:	8b6080e7          	jalr	-1866(ra) # 800022f6 <killed>
    80004a48:	e949                	bnez	a0,80004ada <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004a4a:	85a6                	mv	a1,s1
    80004a4c:	854e                	mv	a0,s3
    80004a4e:	ffffd097          	auipc	ra,0xffffd
    80004a52:	600080e7          	jalr	1536(ra) # 8000204e <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004a56:	2184a703          	lw	a4,536(s1)
    80004a5a:	21c4a783          	lw	a5,540(s1)
    80004a5e:	fcf70de3          	beq	a4,a5,80004a38 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a62:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a64:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004a66:	05505463          	blez	s5,80004aae <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004a6a:	2184a783          	lw	a5,536(s1)
    80004a6e:	21c4a703          	lw	a4,540(s1)
    80004a72:	02f70e63          	beq	a4,a5,80004aae <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004a76:	0017871b          	addiw	a4,a5,1
    80004a7a:	20e4ac23          	sw	a4,536(s1)
    80004a7e:	1ff7f793          	andi	a5,a5,511
    80004a82:	97a6                	add	a5,a5,s1
    80004a84:	0187c783          	lbu	a5,24(a5)
    80004a88:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004a8c:	4685                	li	a3,1
    80004a8e:	fbf40613          	addi	a2,s0,-65
    80004a92:	85ca                	mv	a1,s2
    80004a94:	050a3503          	ld	a0,80(s4)
    80004a98:	ffffd097          	auipc	ra,0xffffd
    80004a9c:	bce080e7          	jalr	-1074(ra) # 80001666 <copyout>
    80004aa0:	01650763          	beq	a0,s6,80004aae <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004aa4:	2985                	addiw	s3,s3,1
    80004aa6:	0905                	addi	s2,s2,1
    80004aa8:	fd3a91e3          	bne	s5,s3,80004a6a <piperead+0x70>
    80004aac:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004aae:	21c48513          	addi	a0,s1,540
    80004ab2:	ffffd097          	auipc	ra,0xffffd
    80004ab6:	600080e7          	jalr	1536(ra) # 800020b2 <wakeup>
  release(&pi->lock);
    80004aba:	8526                	mv	a0,s1
    80004abc:	ffffc097          	auipc	ra,0xffffc
    80004ac0:	1ca080e7          	jalr	458(ra) # 80000c86 <release>
  return i;
}
    80004ac4:	854e                	mv	a0,s3
    80004ac6:	60a6                	ld	ra,72(sp)
    80004ac8:	6406                	ld	s0,64(sp)
    80004aca:	74e2                	ld	s1,56(sp)
    80004acc:	7942                	ld	s2,48(sp)
    80004ace:	79a2                	ld	s3,40(sp)
    80004ad0:	7a02                	ld	s4,32(sp)
    80004ad2:	6ae2                	ld	s5,24(sp)
    80004ad4:	6b42                	ld	s6,16(sp)
    80004ad6:	6161                	addi	sp,sp,80
    80004ad8:	8082                	ret
      release(&pi->lock);
    80004ada:	8526                	mv	a0,s1
    80004adc:	ffffc097          	auipc	ra,0xffffc
    80004ae0:	1aa080e7          	jalr	426(ra) # 80000c86 <release>
      return -1;
    80004ae4:	59fd                	li	s3,-1
    80004ae6:	bff9                	j	80004ac4 <piperead+0xca>

0000000080004ae8 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004ae8:	1141                	addi	sp,sp,-16
    80004aea:	e422                	sd	s0,8(sp)
    80004aec:	0800                	addi	s0,sp,16
    80004aee:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004af0:	8905                	andi	a0,a0,1
    80004af2:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004af4:	8b89                	andi	a5,a5,2
    80004af6:	c399                	beqz	a5,80004afc <flags2perm+0x14>
      perm |= PTE_W;
    80004af8:	00456513          	ori	a0,a0,4
    return perm;
}
    80004afc:	6422                	ld	s0,8(sp)
    80004afe:	0141                	addi	sp,sp,16
    80004b00:	8082                	ret

0000000080004b02 <exec>:

int
exec(char *path, char **argv)
{
    80004b02:	df010113          	addi	sp,sp,-528
    80004b06:	20113423          	sd	ra,520(sp)
    80004b0a:	20813023          	sd	s0,512(sp)
    80004b0e:	ffa6                	sd	s1,504(sp)
    80004b10:	fbca                	sd	s2,496(sp)
    80004b12:	f7ce                	sd	s3,488(sp)
    80004b14:	f3d2                	sd	s4,480(sp)
    80004b16:	efd6                	sd	s5,472(sp)
    80004b18:	ebda                	sd	s6,464(sp)
    80004b1a:	e7de                	sd	s7,456(sp)
    80004b1c:	e3e2                	sd	s8,448(sp)
    80004b1e:	ff66                	sd	s9,440(sp)
    80004b20:	fb6a                	sd	s10,432(sp)
    80004b22:	f76e                	sd	s11,424(sp)
    80004b24:	0c00                	addi	s0,sp,528
    80004b26:	892a                	mv	s2,a0
    80004b28:	dea43c23          	sd	a0,-520(s0)
    80004b2c:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004b30:	ffffd097          	auipc	ra,0xffffd
    80004b34:	e76080e7          	jalr	-394(ra) # 800019a6 <myproc>
    80004b38:	84aa                	mv	s1,a0

  begin_op();
    80004b3a:	fffff097          	auipc	ra,0xfffff
    80004b3e:	48e080e7          	jalr	1166(ra) # 80003fc8 <begin_op>

  if((ip = namei(path)) == 0){
    80004b42:	854a                	mv	a0,s2
    80004b44:	fffff097          	auipc	ra,0xfffff
    80004b48:	284080e7          	jalr	644(ra) # 80003dc8 <namei>
    80004b4c:	c92d                	beqz	a0,80004bbe <exec+0xbc>
    80004b4e:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004b50:	fffff097          	auipc	ra,0xfffff
    80004b54:	ad2080e7          	jalr	-1326(ra) # 80003622 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004b58:	04000713          	li	a4,64
    80004b5c:	4681                	li	a3,0
    80004b5e:	e5040613          	addi	a2,s0,-432
    80004b62:	4581                	li	a1,0
    80004b64:	8552                	mv	a0,s4
    80004b66:	fffff097          	auipc	ra,0xfffff
    80004b6a:	d70080e7          	jalr	-656(ra) # 800038d6 <readi>
    80004b6e:	04000793          	li	a5,64
    80004b72:	00f51a63          	bne	a0,a5,80004b86 <exec+0x84>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004b76:	e5042703          	lw	a4,-432(s0)
    80004b7a:	464c47b7          	lui	a5,0x464c4
    80004b7e:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004b82:	04f70463          	beq	a4,a5,80004bca <exec+0xc8>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004b86:	8552                	mv	a0,s4
    80004b88:	fffff097          	auipc	ra,0xfffff
    80004b8c:	cfc080e7          	jalr	-772(ra) # 80003884 <iunlockput>
    end_op();
    80004b90:	fffff097          	auipc	ra,0xfffff
    80004b94:	4b2080e7          	jalr	1202(ra) # 80004042 <end_op>
  }
  return -1;
    80004b98:	557d                	li	a0,-1
}
    80004b9a:	20813083          	ld	ra,520(sp)
    80004b9e:	20013403          	ld	s0,512(sp)
    80004ba2:	74fe                	ld	s1,504(sp)
    80004ba4:	795e                	ld	s2,496(sp)
    80004ba6:	79be                	ld	s3,488(sp)
    80004ba8:	7a1e                	ld	s4,480(sp)
    80004baa:	6afe                	ld	s5,472(sp)
    80004bac:	6b5e                	ld	s6,464(sp)
    80004bae:	6bbe                	ld	s7,456(sp)
    80004bb0:	6c1e                	ld	s8,448(sp)
    80004bb2:	7cfa                	ld	s9,440(sp)
    80004bb4:	7d5a                	ld	s10,432(sp)
    80004bb6:	7dba                	ld	s11,424(sp)
    80004bb8:	21010113          	addi	sp,sp,528
    80004bbc:	8082                	ret
    end_op();
    80004bbe:	fffff097          	auipc	ra,0xfffff
    80004bc2:	484080e7          	jalr	1156(ra) # 80004042 <end_op>
    return -1;
    80004bc6:	557d                	li	a0,-1
    80004bc8:	bfc9                	j	80004b9a <exec+0x98>
  if((pagetable = proc_pagetable(p)) == 0)
    80004bca:	8526                	mv	a0,s1
    80004bcc:	ffffd097          	auipc	ra,0xffffd
    80004bd0:	e9e080e7          	jalr	-354(ra) # 80001a6a <proc_pagetable>
    80004bd4:	8b2a                	mv	s6,a0
    80004bd6:	d945                	beqz	a0,80004b86 <exec+0x84>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004bd8:	e7042d03          	lw	s10,-400(s0)
    80004bdc:	e8845783          	lhu	a5,-376(s0)
    80004be0:	10078463          	beqz	a5,80004ce8 <exec+0x1e6>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004be4:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004be6:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    80004be8:	6c85                	lui	s9,0x1
    80004bea:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    80004bee:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004bf2:	6a85                	lui	s5,0x1
    80004bf4:	a0b5                	j	80004c60 <exec+0x15e>
      panic("loadseg: address should exist");
    80004bf6:	00004517          	auipc	a0,0x4
    80004bfa:	ada50513          	addi	a0,a0,-1318 # 800086d0 <syscalls+0x280>
    80004bfe:	ffffc097          	auipc	ra,0xffffc
    80004c02:	93e080e7          	jalr	-1730(ra) # 8000053c <panic>
    if(sz - i < PGSIZE)
    80004c06:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004c08:	8726                	mv	a4,s1
    80004c0a:	012c06bb          	addw	a3,s8,s2
    80004c0e:	4581                	li	a1,0
    80004c10:	8552                	mv	a0,s4
    80004c12:	fffff097          	auipc	ra,0xfffff
    80004c16:	cc4080e7          	jalr	-828(ra) # 800038d6 <readi>
    80004c1a:	2501                	sext.w	a0,a0
    80004c1c:	24a49863          	bne	s1,a0,80004e6c <exec+0x36a>
  for(i = 0; i < sz; i += PGSIZE){
    80004c20:	012a893b          	addw	s2,s5,s2
    80004c24:	03397563          	bgeu	s2,s3,80004c4e <exec+0x14c>
    pa = walkaddr(pagetable, va + i);
    80004c28:	02091593          	slli	a1,s2,0x20
    80004c2c:	9181                	srli	a1,a1,0x20
    80004c2e:	95de                	add	a1,a1,s7
    80004c30:	855a                	mv	a0,s6
    80004c32:	ffffc097          	auipc	ra,0xffffc
    80004c36:	424080e7          	jalr	1060(ra) # 80001056 <walkaddr>
    80004c3a:	862a                	mv	a2,a0
    if(pa == 0)
    80004c3c:	dd4d                	beqz	a0,80004bf6 <exec+0xf4>
    if(sz - i < PGSIZE)
    80004c3e:	412984bb          	subw	s1,s3,s2
    80004c42:	0004879b          	sext.w	a5,s1
    80004c46:	fcfcf0e3          	bgeu	s9,a5,80004c06 <exec+0x104>
    80004c4a:	84d6                	mv	s1,s5
    80004c4c:	bf6d                	j	80004c06 <exec+0x104>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004c4e:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004c52:	2d85                	addiw	s11,s11,1
    80004c54:	038d0d1b          	addiw	s10,s10,56
    80004c58:	e8845783          	lhu	a5,-376(s0)
    80004c5c:	08fdd763          	bge	s11,a5,80004cea <exec+0x1e8>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004c60:	2d01                	sext.w	s10,s10
    80004c62:	03800713          	li	a4,56
    80004c66:	86ea                	mv	a3,s10
    80004c68:	e1840613          	addi	a2,s0,-488
    80004c6c:	4581                	li	a1,0
    80004c6e:	8552                	mv	a0,s4
    80004c70:	fffff097          	auipc	ra,0xfffff
    80004c74:	c66080e7          	jalr	-922(ra) # 800038d6 <readi>
    80004c78:	03800793          	li	a5,56
    80004c7c:	1ef51663          	bne	a0,a5,80004e68 <exec+0x366>
    if(ph.type != ELF_PROG_LOAD)
    80004c80:	e1842783          	lw	a5,-488(s0)
    80004c84:	4705                	li	a4,1
    80004c86:	fce796e3          	bne	a5,a4,80004c52 <exec+0x150>
    if(ph.memsz < ph.filesz)
    80004c8a:	e4043483          	ld	s1,-448(s0)
    80004c8e:	e3843783          	ld	a5,-456(s0)
    80004c92:	1ef4e863          	bltu	s1,a5,80004e82 <exec+0x380>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004c96:	e2843783          	ld	a5,-472(s0)
    80004c9a:	94be                	add	s1,s1,a5
    80004c9c:	1ef4e663          	bltu	s1,a5,80004e88 <exec+0x386>
    if(ph.vaddr % PGSIZE != 0)
    80004ca0:	df043703          	ld	a4,-528(s0)
    80004ca4:	8ff9                	and	a5,a5,a4
    80004ca6:	1e079463          	bnez	a5,80004e8e <exec+0x38c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004caa:	e1c42503          	lw	a0,-484(s0)
    80004cae:	00000097          	auipc	ra,0x0
    80004cb2:	e3a080e7          	jalr	-454(ra) # 80004ae8 <flags2perm>
    80004cb6:	86aa                	mv	a3,a0
    80004cb8:	8626                	mv	a2,s1
    80004cba:	85ca                	mv	a1,s2
    80004cbc:	855a                	mv	a0,s6
    80004cbe:	ffffc097          	auipc	ra,0xffffc
    80004cc2:	74c080e7          	jalr	1868(ra) # 8000140a <uvmalloc>
    80004cc6:	e0a43423          	sd	a0,-504(s0)
    80004cca:	1c050563          	beqz	a0,80004e94 <exec+0x392>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    80004cce:	e2843b83          	ld	s7,-472(s0)
    80004cd2:	e2042c03          	lw	s8,-480(s0)
    80004cd6:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    80004cda:	00098463          	beqz	s3,80004ce2 <exec+0x1e0>
    80004cde:	4901                	li	s2,0
    80004ce0:	b7a1                	j	80004c28 <exec+0x126>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80004ce2:	e0843903          	ld	s2,-504(s0)
    80004ce6:	b7b5                	j	80004c52 <exec+0x150>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004ce8:	4901                	li	s2,0
  iunlockput(ip);
    80004cea:	8552                	mv	a0,s4
    80004cec:	fffff097          	auipc	ra,0xfffff
    80004cf0:	b98080e7          	jalr	-1128(ra) # 80003884 <iunlockput>
  end_op();
    80004cf4:	fffff097          	auipc	ra,0xfffff
    80004cf8:	34e080e7          	jalr	846(ra) # 80004042 <end_op>
  p = myproc();
    80004cfc:	ffffd097          	auipc	ra,0xffffd
    80004d00:	caa080e7          	jalr	-854(ra) # 800019a6 <myproc>
    80004d04:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    80004d06:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    80004d0a:	6985                	lui	s3,0x1
    80004d0c:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    80004d0e:	99ca                	add	s3,s3,s2
    80004d10:	77fd                	lui	a5,0xfffff
    80004d12:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004d16:	4691                	li	a3,4
    80004d18:	6609                	lui	a2,0x2
    80004d1a:	964e                	add	a2,a2,s3
    80004d1c:	85ce                	mv	a1,s3
    80004d1e:	855a                	mv	a0,s6
    80004d20:	ffffc097          	auipc	ra,0xffffc
    80004d24:	6ea080e7          	jalr	1770(ra) # 8000140a <uvmalloc>
    80004d28:	892a                	mv	s2,a0
    80004d2a:	e0a43423          	sd	a0,-504(s0)
    80004d2e:	e509                	bnez	a0,80004d38 <exec+0x236>
  if(pagetable)
    80004d30:	e1343423          	sd	s3,-504(s0)
    80004d34:	4a01                	li	s4,0
    80004d36:	aa1d                	j	80004e6c <exec+0x36a>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004d38:	75f9                	lui	a1,0xffffe
    80004d3a:	95aa                	add	a1,a1,a0
    80004d3c:	855a                	mv	a0,s6
    80004d3e:	ffffd097          	auipc	ra,0xffffd
    80004d42:	8f6080e7          	jalr	-1802(ra) # 80001634 <uvmclear>
  stackbase = sp - PGSIZE;
    80004d46:	7bfd                	lui	s7,0xfffff
    80004d48:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004d4a:	e0043783          	ld	a5,-512(s0)
    80004d4e:	6388                	ld	a0,0(a5)
    80004d50:	c52d                	beqz	a0,80004dba <exec+0x2b8>
    80004d52:	e9040993          	addi	s3,s0,-368
    80004d56:	f9040c13          	addi	s8,s0,-112
    80004d5a:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004d5c:	ffffc097          	auipc	ra,0xffffc
    80004d60:	0ec080e7          	jalr	236(ra) # 80000e48 <strlen>
    80004d64:	0015079b          	addiw	a5,a0,1
    80004d68:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004d6c:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004d70:	13796563          	bltu	s2,s7,80004e9a <exec+0x398>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004d74:	e0043d03          	ld	s10,-512(s0)
    80004d78:	000d3a03          	ld	s4,0(s10)
    80004d7c:	8552                	mv	a0,s4
    80004d7e:	ffffc097          	auipc	ra,0xffffc
    80004d82:	0ca080e7          	jalr	202(ra) # 80000e48 <strlen>
    80004d86:	0015069b          	addiw	a3,a0,1
    80004d8a:	8652                	mv	a2,s4
    80004d8c:	85ca                	mv	a1,s2
    80004d8e:	855a                	mv	a0,s6
    80004d90:	ffffd097          	auipc	ra,0xffffd
    80004d94:	8d6080e7          	jalr	-1834(ra) # 80001666 <copyout>
    80004d98:	10054363          	bltz	a0,80004e9e <exec+0x39c>
    ustack[argc] = sp;
    80004d9c:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004da0:	0485                	addi	s1,s1,1
    80004da2:	008d0793          	addi	a5,s10,8
    80004da6:	e0f43023          	sd	a5,-512(s0)
    80004daa:	008d3503          	ld	a0,8(s10)
    80004dae:	c909                	beqz	a0,80004dc0 <exec+0x2be>
    if(argc >= MAXARG)
    80004db0:	09a1                	addi	s3,s3,8
    80004db2:	fb8995e3          	bne	s3,s8,80004d5c <exec+0x25a>
  ip = 0;
    80004db6:	4a01                	li	s4,0
    80004db8:	a855                	j	80004e6c <exec+0x36a>
  sp = sz;
    80004dba:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004dbe:	4481                	li	s1,0
  ustack[argc] = 0;
    80004dc0:	00349793          	slli	a5,s1,0x3
    80004dc4:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdd250>
    80004dc8:	97a2                	add	a5,a5,s0
    80004dca:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80004dce:	00148693          	addi	a3,s1,1
    80004dd2:	068e                	slli	a3,a3,0x3
    80004dd4:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004dd8:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    80004ddc:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    80004de0:	f57968e3          	bltu	s2,s7,80004d30 <exec+0x22e>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    80004de4:	e9040613          	addi	a2,s0,-368
    80004de8:	85ca                	mv	a1,s2
    80004dea:	855a                	mv	a0,s6
    80004dec:	ffffd097          	auipc	ra,0xffffd
    80004df0:	87a080e7          	jalr	-1926(ra) # 80001666 <copyout>
    80004df4:	0a054763          	bltz	a0,80004ea2 <exec+0x3a0>
  p->trapframe->a1 = sp;
    80004df8:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    80004dfc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80004e00:	df843783          	ld	a5,-520(s0)
    80004e04:	0007c703          	lbu	a4,0(a5)
    80004e08:	cf11                	beqz	a4,80004e24 <exec+0x322>
    80004e0a:	0785                	addi	a5,a5,1
    if(*s == '/')
    80004e0c:	02f00693          	li	a3,47
    80004e10:	a039                	j	80004e1e <exec+0x31c>
      last = s+1;
    80004e12:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    80004e16:	0785                	addi	a5,a5,1
    80004e18:	fff7c703          	lbu	a4,-1(a5)
    80004e1c:	c701                	beqz	a4,80004e24 <exec+0x322>
    if(*s == '/')
    80004e1e:	fed71ce3          	bne	a4,a3,80004e16 <exec+0x314>
    80004e22:	bfc5                	j	80004e12 <exec+0x310>
  safestrcpy(p->name, last, sizeof(p->name));
    80004e24:	4641                	li	a2,16
    80004e26:	df843583          	ld	a1,-520(s0)
    80004e2a:	158a8513          	addi	a0,s5,344
    80004e2e:	ffffc097          	auipc	ra,0xffffc
    80004e32:	fe8080e7          	jalr	-24(ra) # 80000e16 <safestrcpy>
  oldpagetable = p->pagetable;
    80004e36:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    80004e3a:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004e3e:	e0843783          	ld	a5,-504(s0)
    80004e42:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004e46:	058ab783          	ld	a5,88(s5)
    80004e4a:	e6843703          	ld	a4,-408(s0)
    80004e4e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004e50:	058ab783          	ld	a5,88(s5)
    80004e54:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004e58:	85e6                	mv	a1,s9
    80004e5a:	ffffd097          	auipc	ra,0xffffd
    80004e5e:	cac080e7          	jalr	-852(ra) # 80001b06 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004e62:	0004851b          	sext.w	a0,s1
    80004e66:	bb15                	j	80004b9a <exec+0x98>
    80004e68:	e1243423          	sd	s2,-504(s0)
    proc_freepagetable(pagetable, sz);
    80004e6c:	e0843583          	ld	a1,-504(s0)
    80004e70:	855a                	mv	a0,s6
    80004e72:	ffffd097          	auipc	ra,0xffffd
    80004e76:	c94080e7          	jalr	-876(ra) # 80001b06 <proc_freepagetable>
  return -1;
    80004e7a:	557d                	li	a0,-1
  if(ip){
    80004e7c:	d00a0fe3          	beqz	s4,80004b9a <exec+0x98>
    80004e80:	b319                	j	80004b86 <exec+0x84>
    80004e82:	e1243423          	sd	s2,-504(s0)
    80004e86:	b7dd                	j	80004e6c <exec+0x36a>
    80004e88:	e1243423          	sd	s2,-504(s0)
    80004e8c:	b7c5                	j	80004e6c <exec+0x36a>
    80004e8e:	e1243423          	sd	s2,-504(s0)
    80004e92:	bfe9                	j	80004e6c <exec+0x36a>
    80004e94:	e1243423          	sd	s2,-504(s0)
    80004e98:	bfd1                	j	80004e6c <exec+0x36a>
  ip = 0;
    80004e9a:	4a01                	li	s4,0
    80004e9c:	bfc1                	j	80004e6c <exec+0x36a>
    80004e9e:	4a01                	li	s4,0
  if(pagetable)
    80004ea0:	b7f1                	j	80004e6c <exec+0x36a>
  sz = sz1;
    80004ea2:	e0843983          	ld	s3,-504(s0)
    80004ea6:	b569                	j	80004d30 <exec+0x22e>

0000000080004ea8 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    80004ea8:	7179                	addi	sp,sp,-48
    80004eaa:	f406                	sd	ra,40(sp)
    80004eac:	f022                	sd	s0,32(sp)
    80004eae:	ec26                	sd	s1,24(sp)
    80004eb0:	e84a                	sd	s2,16(sp)
    80004eb2:	1800                	addi	s0,sp,48
    80004eb4:	892e                	mv	s2,a1
    80004eb6:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    80004eb8:	fdc40593          	addi	a1,s0,-36
    80004ebc:	ffffe097          	auipc	ra,0xffffe
    80004ec0:	c04080e7          	jalr	-1020(ra) # 80002ac0 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004ec4:	fdc42703          	lw	a4,-36(s0)
    80004ec8:	47bd                	li	a5,15
    80004eca:	02e7eb63          	bltu	a5,a4,80004f00 <argfd+0x58>
    80004ece:	ffffd097          	auipc	ra,0xffffd
    80004ed2:	ad8080e7          	jalr	-1320(ra) # 800019a6 <myproc>
    80004ed6:	fdc42703          	lw	a4,-36(s0)
    80004eda:	01a70793          	addi	a5,a4,26
    80004ede:	078e                	slli	a5,a5,0x3
    80004ee0:	953e                	add	a0,a0,a5
    80004ee2:	611c                	ld	a5,0(a0)
    80004ee4:	c385                	beqz	a5,80004f04 <argfd+0x5c>
    return -1;
  if(pfd)
    80004ee6:	00090463          	beqz	s2,80004eee <argfd+0x46>
    *pfd = fd;
    80004eea:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80004eee:	4501                	li	a0,0
  if(pf)
    80004ef0:	c091                	beqz	s1,80004ef4 <argfd+0x4c>
    *pf = f;
    80004ef2:	e09c                	sd	a5,0(s1)
}
    80004ef4:	70a2                	ld	ra,40(sp)
    80004ef6:	7402                	ld	s0,32(sp)
    80004ef8:	64e2                	ld	s1,24(sp)
    80004efa:	6942                	ld	s2,16(sp)
    80004efc:	6145                	addi	sp,sp,48
    80004efe:	8082                	ret
    return -1;
    80004f00:	557d                	li	a0,-1
    80004f02:	bfcd                	j	80004ef4 <argfd+0x4c>
    80004f04:	557d                	li	a0,-1
    80004f06:	b7fd                	j	80004ef4 <argfd+0x4c>

0000000080004f08 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    80004f08:	1101                	addi	sp,sp,-32
    80004f0a:	ec06                	sd	ra,24(sp)
    80004f0c:	e822                	sd	s0,16(sp)
    80004f0e:	e426                	sd	s1,8(sp)
    80004f10:	1000                	addi	s0,sp,32
    80004f12:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004f14:	ffffd097          	auipc	ra,0xffffd
    80004f18:	a92080e7          	jalr	-1390(ra) # 800019a6 <myproc>
    80004f1c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80004f1e:	0d050793          	addi	a5,a0,208
    80004f22:	4501                	li	a0,0
    80004f24:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004f26:	6398                	ld	a4,0(a5)
    80004f28:	cb19                	beqz	a4,80004f3e <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    80004f2a:	2505                	addiw	a0,a0,1
    80004f2c:	07a1                	addi	a5,a5,8
    80004f2e:	fed51ce3          	bne	a0,a3,80004f26 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004f32:	557d                	li	a0,-1
}
    80004f34:	60e2                	ld	ra,24(sp)
    80004f36:	6442                	ld	s0,16(sp)
    80004f38:	64a2                	ld	s1,8(sp)
    80004f3a:	6105                	addi	sp,sp,32
    80004f3c:	8082                	ret
      p->ofile[fd] = f;
    80004f3e:	01a50793          	addi	a5,a0,26
    80004f42:	078e                	slli	a5,a5,0x3
    80004f44:	963e                	add	a2,a2,a5
    80004f46:	e204                	sd	s1,0(a2)
      return fd;
    80004f48:	b7f5                	j	80004f34 <fdalloc+0x2c>

0000000080004f4a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    80004f4a:	715d                	addi	sp,sp,-80
    80004f4c:	e486                	sd	ra,72(sp)
    80004f4e:	e0a2                	sd	s0,64(sp)
    80004f50:	fc26                	sd	s1,56(sp)
    80004f52:	f84a                	sd	s2,48(sp)
    80004f54:	f44e                	sd	s3,40(sp)
    80004f56:	f052                	sd	s4,32(sp)
    80004f58:	ec56                	sd	s5,24(sp)
    80004f5a:	e85a                	sd	s6,16(sp)
    80004f5c:	0880                	addi	s0,sp,80
    80004f5e:	8b2e                	mv	s6,a1
    80004f60:	89b2                	mv	s3,a2
    80004f62:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004f64:	fb040593          	addi	a1,s0,-80
    80004f68:	fffff097          	auipc	ra,0xfffff
    80004f6c:	e7e080e7          	jalr	-386(ra) # 80003de6 <nameiparent>
    80004f70:	84aa                	mv	s1,a0
    80004f72:	14050b63          	beqz	a0,800050c8 <create+0x17e>
    return 0;

  ilock(dp);
    80004f76:	ffffe097          	auipc	ra,0xffffe
    80004f7a:	6ac080e7          	jalr	1708(ra) # 80003622 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004f7e:	4601                	li	a2,0
    80004f80:	fb040593          	addi	a1,s0,-80
    80004f84:	8526                	mv	a0,s1
    80004f86:	fffff097          	auipc	ra,0xfffff
    80004f8a:	b80080e7          	jalr	-1152(ra) # 80003b06 <dirlookup>
    80004f8e:	8aaa                	mv	s5,a0
    80004f90:	c921                	beqz	a0,80004fe0 <create+0x96>
    iunlockput(dp);
    80004f92:	8526                	mv	a0,s1
    80004f94:	fffff097          	auipc	ra,0xfffff
    80004f98:	8f0080e7          	jalr	-1808(ra) # 80003884 <iunlockput>
    ilock(ip);
    80004f9c:	8556                	mv	a0,s5
    80004f9e:	ffffe097          	auipc	ra,0xffffe
    80004fa2:	684080e7          	jalr	1668(ra) # 80003622 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004fa6:	4789                	li	a5,2
    80004fa8:	02fb1563          	bne	s6,a5,80004fd2 <create+0x88>
    80004fac:	044ad783          	lhu	a5,68(s5)
    80004fb0:	37f9                	addiw	a5,a5,-2
    80004fb2:	17c2                	slli	a5,a5,0x30
    80004fb4:	93c1                	srli	a5,a5,0x30
    80004fb6:	4705                	li	a4,1
    80004fb8:	00f76d63          	bltu	a4,a5,80004fd2 <create+0x88>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80004fbc:	8556                	mv	a0,s5
    80004fbe:	60a6                	ld	ra,72(sp)
    80004fc0:	6406                	ld	s0,64(sp)
    80004fc2:	74e2                	ld	s1,56(sp)
    80004fc4:	7942                	ld	s2,48(sp)
    80004fc6:	79a2                	ld	s3,40(sp)
    80004fc8:	7a02                	ld	s4,32(sp)
    80004fca:	6ae2                	ld	s5,24(sp)
    80004fcc:	6b42                	ld	s6,16(sp)
    80004fce:	6161                	addi	sp,sp,80
    80004fd0:	8082                	ret
    iunlockput(ip);
    80004fd2:	8556                	mv	a0,s5
    80004fd4:	fffff097          	auipc	ra,0xfffff
    80004fd8:	8b0080e7          	jalr	-1872(ra) # 80003884 <iunlockput>
    return 0;
    80004fdc:	4a81                	li	s5,0
    80004fde:	bff9                	j	80004fbc <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0){
    80004fe0:	85da                	mv	a1,s6
    80004fe2:	4088                	lw	a0,0(s1)
    80004fe4:	ffffe097          	auipc	ra,0xffffe
    80004fe8:	4a6080e7          	jalr	1190(ra) # 8000348a <ialloc>
    80004fec:	8a2a                	mv	s4,a0
    80004fee:	c529                	beqz	a0,80005038 <create+0xee>
  ilock(ip);
    80004ff0:	ffffe097          	auipc	ra,0xffffe
    80004ff4:	632080e7          	jalr	1586(ra) # 80003622 <ilock>
  ip->major = major;
    80004ff8:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80004ffc:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005000:	4905                	li	s2,1
    80005002:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    80005006:	8552                	mv	a0,s4
    80005008:	ffffe097          	auipc	ra,0xffffe
    8000500c:	54e080e7          	jalr	1358(ra) # 80003556 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005010:	032b0b63          	beq	s6,s2,80005046 <create+0xfc>
  if(dirlink(dp, name, ip->inum) < 0)
    80005014:	004a2603          	lw	a2,4(s4)
    80005018:	fb040593          	addi	a1,s0,-80
    8000501c:	8526                	mv	a0,s1
    8000501e:	fffff097          	auipc	ra,0xfffff
    80005022:	cf8080e7          	jalr	-776(ra) # 80003d16 <dirlink>
    80005026:	06054f63          	bltz	a0,800050a4 <create+0x15a>
  iunlockput(dp);
    8000502a:	8526                	mv	a0,s1
    8000502c:	fffff097          	auipc	ra,0xfffff
    80005030:	858080e7          	jalr	-1960(ra) # 80003884 <iunlockput>
  return ip;
    80005034:	8ad2                	mv	s5,s4
    80005036:	b759                	j	80004fbc <create+0x72>
    iunlockput(dp);
    80005038:	8526                	mv	a0,s1
    8000503a:	fffff097          	auipc	ra,0xfffff
    8000503e:	84a080e7          	jalr	-1974(ra) # 80003884 <iunlockput>
    return 0;
    80005042:	8ad2                	mv	s5,s4
    80005044:	bfa5                	j	80004fbc <create+0x72>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005046:	004a2603          	lw	a2,4(s4)
    8000504a:	00003597          	auipc	a1,0x3
    8000504e:	6a658593          	addi	a1,a1,1702 # 800086f0 <syscalls+0x2a0>
    80005052:	8552                	mv	a0,s4
    80005054:	fffff097          	auipc	ra,0xfffff
    80005058:	cc2080e7          	jalr	-830(ra) # 80003d16 <dirlink>
    8000505c:	04054463          	bltz	a0,800050a4 <create+0x15a>
    80005060:	40d0                	lw	a2,4(s1)
    80005062:	00003597          	auipc	a1,0x3
    80005066:	69658593          	addi	a1,a1,1686 # 800086f8 <syscalls+0x2a8>
    8000506a:	8552                	mv	a0,s4
    8000506c:	fffff097          	auipc	ra,0xfffff
    80005070:	caa080e7          	jalr	-854(ra) # 80003d16 <dirlink>
    80005074:	02054863          	bltz	a0,800050a4 <create+0x15a>
  if(dirlink(dp, name, ip->inum) < 0)
    80005078:	004a2603          	lw	a2,4(s4)
    8000507c:	fb040593          	addi	a1,s0,-80
    80005080:	8526                	mv	a0,s1
    80005082:	fffff097          	auipc	ra,0xfffff
    80005086:	c94080e7          	jalr	-876(ra) # 80003d16 <dirlink>
    8000508a:	00054d63          	bltz	a0,800050a4 <create+0x15a>
    dp->nlink++;  // for ".."
    8000508e:	04a4d783          	lhu	a5,74(s1)
    80005092:	2785                	addiw	a5,a5,1
    80005094:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005098:	8526                	mv	a0,s1
    8000509a:	ffffe097          	auipc	ra,0xffffe
    8000509e:	4bc080e7          	jalr	1212(ra) # 80003556 <iupdate>
    800050a2:	b761                	j	8000502a <create+0xe0>
  ip->nlink = 0;
    800050a4:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800050a8:	8552                	mv	a0,s4
    800050aa:	ffffe097          	auipc	ra,0xffffe
    800050ae:	4ac080e7          	jalr	1196(ra) # 80003556 <iupdate>
  iunlockput(ip);
    800050b2:	8552                	mv	a0,s4
    800050b4:	ffffe097          	auipc	ra,0xffffe
    800050b8:	7d0080e7          	jalr	2000(ra) # 80003884 <iunlockput>
  iunlockput(dp);
    800050bc:	8526                	mv	a0,s1
    800050be:	ffffe097          	auipc	ra,0xffffe
    800050c2:	7c6080e7          	jalr	1990(ra) # 80003884 <iunlockput>
  return 0;
    800050c6:	bddd                	j	80004fbc <create+0x72>
    return 0;
    800050c8:	8aaa                	mv	s5,a0
    800050ca:	bdcd                	j	80004fbc <create+0x72>

00000000800050cc <sys_dup>:
{
    800050cc:	7179                	addi	sp,sp,-48
    800050ce:	f406                	sd	ra,40(sp)
    800050d0:	f022                	sd	s0,32(sp)
    800050d2:	ec26                	sd	s1,24(sp)
    800050d4:	e84a                	sd	s2,16(sp)
    800050d6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    800050d8:	fd840613          	addi	a2,s0,-40
    800050dc:	4581                	li	a1,0
    800050de:	4501                	li	a0,0
    800050e0:	00000097          	auipc	ra,0x0
    800050e4:	dc8080e7          	jalr	-568(ra) # 80004ea8 <argfd>
    return -1;
    800050e8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    800050ea:	02054363          	bltz	a0,80005110 <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    800050ee:	fd843903          	ld	s2,-40(s0)
    800050f2:	854a                	mv	a0,s2
    800050f4:	00000097          	auipc	ra,0x0
    800050f8:	e14080e7          	jalr	-492(ra) # 80004f08 <fdalloc>
    800050fc:	84aa                	mv	s1,a0
    return -1;
    800050fe:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80005100:	00054863          	bltz	a0,80005110 <sys_dup+0x44>
  filedup(f);
    80005104:	854a                	mv	a0,s2
    80005106:	fffff097          	auipc	ra,0xfffff
    8000510a:	334080e7          	jalr	820(ra) # 8000443a <filedup>
  return fd;
    8000510e:	87a6                	mv	a5,s1
}
    80005110:	853e                	mv	a0,a5
    80005112:	70a2                	ld	ra,40(sp)
    80005114:	7402                	ld	s0,32(sp)
    80005116:	64e2                	ld	s1,24(sp)
    80005118:	6942                	ld	s2,16(sp)
    8000511a:	6145                	addi	sp,sp,48
    8000511c:	8082                	ret

000000008000511e <sys_read>:
{
    8000511e:	7179                	addi	sp,sp,-48
    80005120:	f406                	sd	ra,40(sp)
    80005122:	f022                	sd	s0,32(sp)
    80005124:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005126:	fd840593          	addi	a1,s0,-40
    8000512a:	4505                	li	a0,1
    8000512c:	ffffe097          	auipc	ra,0xffffe
    80005130:	9b4080e7          	jalr	-1612(ra) # 80002ae0 <argaddr>
  argint(2, &n);
    80005134:	fe440593          	addi	a1,s0,-28
    80005138:	4509                	li	a0,2
    8000513a:	ffffe097          	auipc	ra,0xffffe
    8000513e:	986080e7          	jalr	-1658(ra) # 80002ac0 <argint>
  if(argfd(0, 0, &f) < 0)
    80005142:	fe840613          	addi	a2,s0,-24
    80005146:	4581                	li	a1,0
    80005148:	4501                	li	a0,0
    8000514a:	00000097          	auipc	ra,0x0
    8000514e:	d5e080e7          	jalr	-674(ra) # 80004ea8 <argfd>
    80005152:	87aa                	mv	a5,a0
    return -1;
    80005154:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005156:	0007cc63          	bltz	a5,8000516e <sys_read+0x50>
  return fileread(f, p, n);
    8000515a:	fe442603          	lw	a2,-28(s0)
    8000515e:	fd843583          	ld	a1,-40(s0)
    80005162:	fe843503          	ld	a0,-24(s0)
    80005166:	fffff097          	auipc	ra,0xfffff
    8000516a:	460080e7          	jalr	1120(ra) # 800045c6 <fileread>
}
    8000516e:	70a2                	ld	ra,40(sp)
    80005170:	7402                	ld	s0,32(sp)
    80005172:	6145                	addi	sp,sp,48
    80005174:	8082                	ret

0000000080005176 <sys_write>:
{
    80005176:	7179                	addi	sp,sp,-48
    80005178:	f406                	sd	ra,40(sp)
    8000517a:	f022                	sd	s0,32(sp)
    8000517c:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    8000517e:	fd840593          	addi	a1,s0,-40
    80005182:	4505                	li	a0,1
    80005184:	ffffe097          	auipc	ra,0xffffe
    80005188:	95c080e7          	jalr	-1700(ra) # 80002ae0 <argaddr>
  argint(2, &n);
    8000518c:	fe440593          	addi	a1,s0,-28
    80005190:	4509                	li	a0,2
    80005192:	ffffe097          	auipc	ra,0xffffe
    80005196:	92e080e7          	jalr	-1746(ra) # 80002ac0 <argint>
  if(argfd(0, 0, &f) < 0)
    8000519a:	fe840613          	addi	a2,s0,-24
    8000519e:	4581                	li	a1,0
    800051a0:	4501                	li	a0,0
    800051a2:	00000097          	auipc	ra,0x0
    800051a6:	d06080e7          	jalr	-762(ra) # 80004ea8 <argfd>
    800051aa:	87aa                	mv	a5,a0
    return -1;
    800051ac:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800051ae:	0007cc63          	bltz	a5,800051c6 <sys_write+0x50>
  return filewrite(f, p, n);
    800051b2:	fe442603          	lw	a2,-28(s0)
    800051b6:	fd843583          	ld	a1,-40(s0)
    800051ba:	fe843503          	ld	a0,-24(s0)
    800051be:	fffff097          	auipc	ra,0xfffff
    800051c2:	4ca080e7          	jalr	1226(ra) # 80004688 <filewrite>
}
    800051c6:	70a2                	ld	ra,40(sp)
    800051c8:	7402                	ld	s0,32(sp)
    800051ca:	6145                	addi	sp,sp,48
    800051cc:	8082                	ret

00000000800051ce <sys_close>:
{
    800051ce:	1101                	addi	sp,sp,-32
    800051d0:	ec06                	sd	ra,24(sp)
    800051d2:	e822                	sd	s0,16(sp)
    800051d4:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    800051d6:	fe040613          	addi	a2,s0,-32
    800051da:	fec40593          	addi	a1,s0,-20
    800051de:	4501                	li	a0,0
    800051e0:	00000097          	auipc	ra,0x0
    800051e4:	cc8080e7          	jalr	-824(ra) # 80004ea8 <argfd>
    return -1;
    800051e8:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    800051ea:	02054463          	bltz	a0,80005212 <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    800051ee:	ffffc097          	auipc	ra,0xffffc
    800051f2:	7b8080e7          	jalr	1976(ra) # 800019a6 <myproc>
    800051f6:	fec42783          	lw	a5,-20(s0)
    800051fa:	07e9                	addi	a5,a5,26
    800051fc:	078e                	slli	a5,a5,0x3
    800051fe:	953e                	add	a0,a0,a5
    80005200:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80005204:	fe043503          	ld	a0,-32(s0)
    80005208:	fffff097          	auipc	ra,0xfffff
    8000520c:	284080e7          	jalr	644(ra) # 8000448c <fileclose>
  return 0;
    80005210:	4781                	li	a5,0
}
    80005212:	853e                	mv	a0,a5
    80005214:	60e2                	ld	ra,24(sp)
    80005216:	6442                	ld	s0,16(sp)
    80005218:	6105                	addi	sp,sp,32
    8000521a:	8082                	ret

000000008000521c <sys_fstat>:
{
    8000521c:	1101                	addi	sp,sp,-32
    8000521e:	ec06                	sd	ra,24(sp)
    80005220:	e822                	sd	s0,16(sp)
    80005222:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80005224:	fe040593          	addi	a1,s0,-32
    80005228:	4505                	li	a0,1
    8000522a:	ffffe097          	auipc	ra,0xffffe
    8000522e:	8b6080e7          	jalr	-1866(ra) # 80002ae0 <argaddr>
  if(argfd(0, 0, &f) < 0)
    80005232:	fe840613          	addi	a2,s0,-24
    80005236:	4581                	li	a1,0
    80005238:	4501                	li	a0,0
    8000523a:	00000097          	auipc	ra,0x0
    8000523e:	c6e080e7          	jalr	-914(ra) # 80004ea8 <argfd>
    80005242:	87aa                	mv	a5,a0
    return -1;
    80005244:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005246:	0007ca63          	bltz	a5,8000525a <sys_fstat+0x3e>
  return filestat(f, st);
    8000524a:	fe043583          	ld	a1,-32(s0)
    8000524e:	fe843503          	ld	a0,-24(s0)
    80005252:	fffff097          	auipc	ra,0xfffff
    80005256:	302080e7          	jalr	770(ra) # 80004554 <filestat>
}
    8000525a:	60e2                	ld	ra,24(sp)
    8000525c:	6442                	ld	s0,16(sp)
    8000525e:	6105                	addi	sp,sp,32
    80005260:	8082                	ret

0000000080005262 <sys_link>:
{
    80005262:	7169                	addi	sp,sp,-304
    80005264:	f606                	sd	ra,296(sp)
    80005266:	f222                	sd	s0,288(sp)
    80005268:	ee26                	sd	s1,280(sp)
    8000526a:	ea4a                	sd	s2,272(sp)
    8000526c:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000526e:	08000613          	li	a2,128
    80005272:	ed040593          	addi	a1,s0,-304
    80005276:	4501                	li	a0,0
    80005278:	ffffe097          	auipc	ra,0xffffe
    8000527c:	888080e7          	jalr	-1912(ra) # 80002b00 <argstr>
    return -1;
    80005280:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80005282:	10054e63          	bltz	a0,8000539e <sys_link+0x13c>
    80005286:	08000613          	li	a2,128
    8000528a:	f5040593          	addi	a1,s0,-176
    8000528e:	4505                	li	a0,1
    80005290:	ffffe097          	auipc	ra,0xffffe
    80005294:	870080e7          	jalr	-1936(ra) # 80002b00 <argstr>
    return -1;
    80005298:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    8000529a:	10054263          	bltz	a0,8000539e <sys_link+0x13c>
  begin_op();
    8000529e:	fffff097          	auipc	ra,0xfffff
    800052a2:	d2a080e7          	jalr	-726(ra) # 80003fc8 <begin_op>
  if((ip = namei(old)) == 0){
    800052a6:	ed040513          	addi	a0,s0,-304
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	b1e080e7          	jalr	-1250(ra) # 80003dc8 <namei>
    800052b2:	84aa                	mv	s1,a0
    800052b4:	c551                	beqz	a0,80005340 <sys_link+0xde>
  ilock(ip);
    800052b6:	ffffe097          	auipc	ra,0xffffe
    800052ba:	36c080e7          	jalr	876(ra) # 80003622 <ilock>
  if(ip->type == T_DIR){
    800052be:	04449703          	lh	a4,68(s1)
    800052c2:	4785                	li	a5,1
    800052c4:	08f70463          	beq	a4,a5,8000534c <sys_link+0xea>
  ip->nlink++;
    800052c8:	04a4d783          	lhu	a5,74(s1)
    800052cc:	2785                	addiw	a5,a5,1
    800052ce:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800052d2:	8526                	mv	a0,s1
    800052d4:	ffffe097          	auipc	ra,0xffffe
    800052d8:	282080e7          	jalr	642(ra) # 80003556 <iupdate>
  iunlock(ip);
    800052dc:	8526                	mv	a0,s1
    800052de:	ffffe097          	auipc	ra,0xffffe
    800052e2:	406080e7          	jalr	1030(ra) # 800036e4 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    800052e6:	fd040593          	addi	a1,s0,-48
    800052ea:	f5040513          	addi	a0,s0,-176
    800052ee:	fffff097          	auipc	ra,0xfffff
    800052f2:	af8080e7          	jalr	-1288(ra) # 80003de6 <nameiparent>
    800052f6:	892a                	mv	s2,a0
    800052f8:	c935                	beqz	a0,8000536c <sys_link+0x10a>
  ilock(dp);
    800052fa:	ffffe097          	auipc	ra,0xffffe
    800052fe:	328080e7          	jalr	808(ra) # 80003622 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80005302:	00092703          	lw	a4,0(s2)
    80005306:	409c                	lw	a5,0(s1)
    80005308:	04f71d63          	bne	a4,a5,80005362 <sys_link+0x100>
    8000530c:	40d0                	lw	a2,4(s1)
    8000530e:	fd040593          	addi	a1,s0,-48
    80005312:	854a                	mv	a0,s2
    80005314:	fffff097          	auipc	ra,0xfffff
    80005318:	a02080e7          	jalr	-1534(ra) # 80003d16 <dirlink>
    8000531c:	04054363          	bltz	a0,80005362 <sys_link+0x100>
  iunlockput(dp);
    80005320:	854a                	mv	a0,s2
    80005322:	ffffe097          	auipc	ra,0xffffe
    80005326:	562080e7          	jalr	1378(ra) # 80003884 <iunlockput>
  iput(ip);
    8000532a:	8526                	mv	a0,s1
    8000532c:	ffffe097          	auipc	ra,0xffffe
    80005330:	4b0080e7          	jalr	1200(ra) # 800037dc <iput>
  end_op();
    80005334:	fffff097          	auipc	ra,0xfffff
    80005338:	d0e080e7          	jalr	-754(ra) # 80004042 <end_op>
  return 0;
    8000533c:	4781                	li	a5,0
    8000533e:	a085                	j	8000539e <sys_link+0x13c>
    end_op();
    80005340:	fffff097          	auipc	ra,0xfffff
    80005344:	d02080e7          	jalr	-766(ra) # 80004042 <end_op>
    return -1;
    80005348:	57fd                	li	a5,-1
    8000534a:	a891                	j	8000539e <sys_link+0x13c>
    iunlockput(ip);
    8000534c:	8526                	mv	a0,s1
    8000534e:	ffffe097          	auipc	ra,0xffffe
    80005352:	536080e7          	jalr	1334(ra) # 80003884 <iunlockput>
    end_op();
    80005356:	fffff097          	auipc	ra,0xfffff
    8000535a:	cec080e7          	jalr	-788(ra) # 80004042 <end_op>
    return -1;
    8000535e:	57fd                	li	a5,-1
    80005360:	a83d                	j	8000539e <sys_link+0x13c>
    iunlockput(dp);
    80005362:	854a                	mv	a0,s2
    80005364:	ffffe097          	auipc	ra,0xffffe
    80005368:	520080e7          	jalr	1312(ra) # 80003884 <iunlockput>
  ilock(ip);
    8000536c:	8526                	mv	a0,s1
    8000536e:	ffffe097          	auipc	ra,0xffffe
    80005372:	2b4080e7          	jalr	692(ra) # 80003622 <ilock>
  ip->nlink--;
    80005376:	04a4d783          	lhu	a5,74(s1)
    8000537a:	37fd                	addiw	a5,a5,-1
    8000537c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80005380:	8526                	mv	a0,s1
    80005382:	ffffe097          	auipc	ra,0xffffe
    80005386:	1d4080e7          	jalr	468(ra) # 80003556 <iupdate>
  iunlockput(ip);
    8000538a:	8526                	mv	a0,s1
    8000538c:	ffffe097          	auipc	ra,0xffffe
    80005390:	4f8080e7          	jalr	1272(ra) # 80003884 <iunlockput>
  end_op();
    80005394:	fffff097          	auipc	ra,0xfffff
    80005398:	cae080e7          	jalr	-850(ra) # 80004042 <end_op>
  return -1;
    8000539c:	57fd                	li	a5,-1
}
    8000539e:	853e                	mv	a0,a5
    800053a0:	70b2                	ld	ra,296(sp)
    800053a2:	7412                	ld	s0,288(sp)
    800053a4:	64f2                	ld	s1,280(sp)
    800053a6:	6952                	ld	s2,272(sp)
    800053a8:	6155                	addi	sp,sp,304
    800053aa:	8082                	ret

00000000800053ac <sys_unlink>:
{
    800053ac:	7151                	addi	sp,sp,-240
    800053ae:	f586                	sd	ra,232(sp)
    800053b0:	f1a2                	sd	s0,224(sp)
    800053b2:	eda6                	sd	s1,216(sp)
    800053b4:	e9ca                	sd	s2,208(sp)
    800053b6:	e5ce                	sd	s3,200(sp)
    800053b8:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    800053ba:	08000613          	li	a2,128
    800053be:	f3040593          	addi	a1,s0,-208
    800053c2:	4501                	li	a0,0
    800053c4:	ffffd097          	auipc	ra,0xffffd
    800053c8:	73c080e7          	jalr	1852(ra) # 80002b00 <argstr>
    800053cc:	18054163          	bltz	a0,8000554e <sys_unlink+0x1a2>
  begin_op();
    800053d0:	fffff097          	auipc	ra,0xfffff
    800053d4:	bf8080e7          	jalr	-1032(ra) # 80003fc8 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    800053d8:	fb040593          	addi	a1,s0,-80
    800053dc:	f3040513          	addi	a0,s0,-208
    800053e0:	fffff097          	auipc	ra,0xfffff
    800053e4:	a06080e7          	jalr	-1530(ra) # 80003de6 <nameiparent>
    800053e8:	84aa                	mv	s1,a0
    800053ea:	c979                	beqz	a0,800054c0 <sys_unlink+0x114>
  ilock(dp);
    800053ec:	ffffe097          	auipc	ra,0xffffe
    800053f0:	236080e7          	jalr	566(ra) # 80003622 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    800053f4:	00003597          	auipc	a1,0x3
    800053f8:	2fc58593          	addi	a1,a1,764 # 800086f0 <syscalls+0x2a0>
    800053fc:	fb040513          	addi	a0,s0,-80
    80005400:	ffffe097          	auipc	ra,0xffffe
    80005404:	6ec080e7          	jalr	1772(ra) # 80003aec <namecmp>
    80005408:	14050a63          	beqz	a0,8000555c <sys_unlink+0x1b0>
    8000540c:	00003597          	auipc	a1,0x3
    80005410:	2ec58593          	addi	a1,a1,748 # 800086f8 <syscalls+0x2a8>
    80005414:	fb040513          	addi	a0,s0,-80
    80005418:	ffffe097          	auipc	ra,0xffffe
    8000541c:	6d4080e7          	jalr	1748(ra) # 80003aec <namecmp>
    80005420:	12050e63          	beqz	a0,8000555c <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80005424:	f2c40613          	addi	a2,s0,-212
    80005428:	fb040593          	addi	a1,s0,-80
    8000542c:	8526                	mv	a0,s1
    8000542e:	ffffe097          	auipc	ra,0xffffe
    80005432:	6d8080e7          	jalr	1752(ra) # 80003b06 <dirlookup>
    80005436:	892a                	mv	s2,a0
    80005438:	12050263          	beqz	a0,8000555c <sys_unlink+0x1b0>
  ilock(ip);
    8000543c:	ffffe097          	auipc	ra,0xffffe
    80005440:	1e6080e7          	jalr	486(ra) # 80003622 <ilock>
  if(ip->nlink < 1)
    80005444:	04a91783          	lh	a5,74(s2)
    80005448:	08f05263          	blez	a5,800054cc <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    8000544c:	04491703          	lh	a4,68(s2)
    80005450:	4785                	li	a5,1
    80005452:	08f70563          	beq	a4,a5,800054dc <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80005456:	4641                	li	a2,16
    80005458:	4581                	li	a1,0
    8000545a:	fc040513          	addi	a0,s0,-64
    8000545e:	ffffc097          	auipc	ra,0xffffc
    80005462:	870080e7          	jalr	-1936(ra) # 80000cce <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005466:	4741                	li	a4,16
    80005468:	f2c42683          	lw	a3,-212(s0)
    8000546c:	fc040613          	addi	a2,s0,-64
    80005470:	4581                	li	a1,0
    80005472:	8526                	mv	a0,s1
    80005474:	ffffe097          	auipc	ra,0xffffe
    80005478:	55a080e7          	jalr	1370(ra) # 800039ce <writei>
    8000547c:	47c1                	li	a5,16
    8000547e:	0af51563          	bne	a0,a5,80005528 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    80005482:	04491703          	lh	a4,68(s2)
    80005486:	4785                	li	a5,1
    80005488:	0af70863          	beq	a4,a5,80005538 <sys_unlink+0x18c>
  iunlockput(dp);
    8000548c:	8526                	mv	a0,s1
    8000548e:	ffffe097          	auipc	ra,0xffffe
    80005492:	3f6080e7          	jalr	1014(ra) # 80003884 <iunlockput>
  ip->nlink--;
    80005496:	04a95783          	lhu	a5,74(s2)
    8000549a:	37fd                	addiw	a5,a5,-1
    8000549c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800054a0:	854a                	mv	a0,s2
    800054a2:	ffffe097          	auipc	ra,0xffffe
    800054a6:	0b4080e7          	jalr	180(ra) # 80003556 <iupdate>
  iunlockput(ip);
    800054aa:	854a                	mv	a0,s2
    800054ac:	ffffe097          	auipc	ra,0xffffe
    800054b0:	3d8080e7          	jalr	984(ra) # 80003884 <iunlockput>
  end_op();
    800054b4:	fffff097          	auipc	ra,0xfffff
    800054b8:	b8e080e7          	jalr	-1138(ra) # 80004042 <end_op>
  return 0;
    800054bc:	4501                	li	a0,0
    800054be:	a84d                	j	80005570 <sys_unlink+0x1c4>
    end_op();
    800054c0:	fffff097          	auipc	ra,0xfffff
    800054c4:	b82080e7          	jalr	-1150(ra) # 80004042 <end_op>
    return -1;
    800054c8:	557d                	li	a0,-1
    800054ca:	a05d                	j	80005570 <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    800054cc:	00003517          	auipc	a0,0x3
    800054d0:	23450513          	addi	a0,a0,564 # 80008700 <syscalls+0x2b0>
    800054d4:	ffffb097          	auipc	ra,0xffffb
    800054d8:	068080e7          	jalr	104(ra) # 8000053c <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    800054dc:	04c92703          	lw	a4,76(s2)
    800054e0:	02000793          	li	a5,32
    800054e4:	f6e7f9e3          	bgeu	a5,a4,80005456 <sys_unlink+0xaa>
    800054e8:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800054ec:	4741                	li	a4,16
    800054ee:	86ce                	mv	a3,s3
    800054f0:	f1840613          	addi	a2,s0,-232
    800054f4:	4581                	li	a1,0
    800054f6:	854a                	mv	a0,s2
    800054f8:	ffffe097          	auipc	ra,0xffffe
    800054fc:	3de080e7          	jalr	990(ra) # 800038d6 <readi>
    80005500:	47c1                	li	a5,16
    80005502:	00f51b63          	bne	a0,a5,80005518 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005506:	f1845783          	lhu	a5,-232(s0)
    8000550a:	e7a1                	bnez	a5,80005552 <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    8000550c:	29c1                	addiw	s3,s3,16
    8000550e:	04c92783          	lw	a5,76(s2)
    80005512:	fcf9ede3          	bltu	s3,a5,800054ec <sys_unlink+0x140>
    80005516:	b781                	j	80005456 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005518:	00003517          	auipc	a0,0x3
    8000551c:	20050513          	addi	a0,a0,512 # 80008718 <syscalls+0x2c8>
    80005520:	ffffb097          	auipc	ra,0xffffb
    80005524:	01c080e7          	jalr	28(ra) # 8000053c <panic>
    panic("unlink: writei");
    80005528:	00003517          	auipc	a0,0x3
    8000552c:	20850513          	addi	a0,a0,520 # 80008730 <syscalls+0x2e0>
    80005530:	ffffb097          	auipc	ra,0xffffb
    80005534:	00c080e7          	jalr	12(ra) # 8000053c <panic>
    dp->nlink--;
    80005538:	04a4d783          	lhu	a5,74(s1)
    8000553c:	37fd                	addiw	a5,a5,-1
    8000553e:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80005542:	8526                	mv	a0,s1
    80005544:	ffffe097          	auipc	ra,0xffffe
    80005548:	012080e7          	jalr	18(ra) # 80003556 <iupdate>
    8000554c:	b781                	j	8000548c <sys_unlink+0xe0>
    return -1;
    8000554e:	557d                	li	a0,-1
    80005550:	a005                	j	80005570 <sys_unlink+0x1c4>
    iunlockput(ip);
    80005552:	854a                	mv	a0,s2
    80005554:	ffffe097          	auipc	ra,0xffffe
    80005558:	330080e7          	jalr	816(ra) # 80003884 <iunlockput>
  iunlockput(dp);
    8000555c:	8526                	mv	a0,s1
    8000555e:	ffffe097          	auipc	ra,0xffffe
    80005562:	326080e7          	jalr	806(ra) # 80003884 <iunlockput>
  end_op();
    80005566:	fffff097          	auipc	ra,0xfffff
    8000556a:	adc080e7          	jalr	-1316(ra) # 80004042 <end_op>
  return -1;
    8000556e:	557d                	li	a0,-1
}
    80005570:	70ae                	ld	ra,232(sp)
    80005572:	740e                	ld	s0,224(sp)
    80005574:	64ee                	ld	s1,216(sp)
    80005576:	694e                	ld	s2,208(sp)
    80005578:	69ae                	ld	s3,200(sp)
    8000557a:	616d                	addi	sp,sp,240
    8000557c:	8082                	ret

000000008000557e <sys_open>:

uint64
sys_open(void)
{
    8000557e:	7131                	addi	sp,sp,-192
    80005580:	fd06                	sd	ra,184(sp)
    80005582:	f922                	sd	s0,176(sp)
    80005584:	f526                	sd	s1,168(sp)
    80005586:	f14a                	sd	s2,160(sp)
    80005588:	ed4e                	sd	s3,152(sp)
    8000558a:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    8000558c:	f4c40593          	addi	a1,s0,-180
    80005590:	4505                	li	a0,1
    80005592:	ffffd097          	auipc	ra,0xffffd
    80005596:	52e080e7          	jalr	1326(ra) # 80002ac0 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    8000559a:	08000613          	li	a2,128
    8000559e:	f5040593          	addi	a1,s0,-176
    800055a2:	4501                	li	a0,0
    800055a4:	ffffd097          	auipc	ra,0xffffd
    800055a8:	55c080e7          	jalr	1372(ra) # 80002b00 <argstr>
    800055ac:	87aa                	mv	a5,a0
    return -1;
    800055ae:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800055b0:	0a07c863          	bltz	a5,80005660 <sys_open+0xe2>

  begin_op();
    800055b4:	fffff097          	auipc	ra,0xfffff
    800055b8:	a14080e7          	jalr	-1516(ra) # 80003fc8 <begin_op>

  if(omode & O_CREATE){
    800055bc:	f4c42783          	lw	a5,-180(s0)
    800055c0:	2007f793          	andi	a5,a5,512
    800055c4:	cbdd                	beqz	a5,8000567a <sys_open+0xfc>
    ip = create(path, T_FILE, 0, 0);
    800055c6:	4681                	li	a3,0
    800055c8:	4601                	li	a2,0
    800055ca:	4589                	li	a1,2
    800055cc:	f5040513          	addi	a0,s0,-176
    800055d0:	00000097          	auipc	ra,0x0
    800055d4:	97a080e7          	jalr	-1670(ra) # 80004f4a <create>
    800055d8:	84aa                	mv	s1,a0
    if(ip == 0){
    800055da:	c951                	beqz	a0,8000566e <sys_open+0xf0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    800055dc:	04449703          	lh	a4,68(s1)
    800055e0:	478d                	li	a5,3
    800055e2:	00f71763          	bne	a4,a5,800055f0 <sys_open+0x72>
    800055e6:	0464d703          	lhu	a4,70(s1)
    800055ea:	47a5                	li	a5,9
    800055ec:	0ce7ec63          	bltu	a5,a4,800056c4 <sys_open+0x146>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    800055f0:	fffff097          	auipc	ra,0xfffff
    800055f4:	de0080e7          	jalr	-544(ra) # 800043d0 <filealloc>
    800055f8:	892a                	mv	s2,a0
    800055fa:	c56d                	beqz	a0,800056e4 <sys_open+0x166>
    800055fc:	00000097          	auipc	ra,0x0
    80005600:	90c080e7          	jalr	-1780(ra) # 80004f08 <fdalloc>
    80005604:	89aa                	mv	s3,a0
    80005606:	0c054a63          	bltz	a0,800056da <sys_open+0x15c>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    8000560a:	04449703          	lh	a4,68(s1)
    8000560e:	478d                	li	a5,3
    80005610:	0ef70563          	beq	a4,a5,800056fa <sys_open+0x17c>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005614:	4789                	li	a5,2
    80005616:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    8000561a:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    8000561e:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80005622:	f4c42783          	lw	a5,-180(s0)
    80005626:	0017c713          	xori	a4,a5,1
    8000562a:	8b05                	andi	a4,a4,1
    8000562c:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80005630:	0037f713          	andi	a4,a5,3
    80005634:	00e03733          	snez	a4,a4
    80005638:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    8000563c:	4007f793          	andi	a5,a5,1024
    80005640:	c791                	beqz	a5,8000564c <sys_open+0xce>
    80005642:	04449703          	lh	a4,68(s1)
    80005646:	4789                	li	a5,2
    80005648:	0cf70063          	beq	a4,a5,80005708 <sys_open+0x18a>
    itrunc(ip);
  }

  iunlock(ip);
    8000564c:	8526                	mv	a0,s1
    8000564e:	ffffe097          	auipc	ra,0xffffe
    80005652:	096080e7          	jalr	150(ra) # 800036e4 <iunlock>
  end_op();
    80005656:	fffff097          	auipc	ra,0xfffff
    8000565a:	9ec080e7          	jalr	-1556(ra) # 80004042 <end_op>

  return fd;
    8000565e:	854e                	mv	a0,s3
}
    80005660:	70ea                	ld	ra,184(sp)
    80005662:	744a                	ld	s0,176(sp)
    80005664:	74aa                	ld	s1,168(sp)
    80005666:	790a                	ld	s2,160(sp)
    80005668:	69ea                	ld	s3,152(sp)
    8000566a:	6129                	addi	sp,sp,192
    8000566c:	8082                	ret
      end_op();
    8000566e:	fffff097          	auipc	ra,0xfffff
    80005672:	9d4080e7          	jalr	-1580(ra) # 80004042 <end_op>
      return -1;
    80005676:	557d                	li	a0,-1
    80005678:	b7e5                	j	80005660 <sys_open+0xe2>
    if((ip = namei(path)) == 0){
    8000567a:	f5040513          	addi	a0,s0,-176
    8000567e:	ffffe097          	auipc	ra,0xffffe
    80005682:	74a080e7          	jalr	1866(ra) # 80003dc8 <namei>
    80005686:	84aa                	mv	s1,a0
    80005688:	c905                	beqz	a0,800056b8 <sys_open+0x13a>
    ilock(ip);
    8000568a:	ffffe097          	auipc	ra,0xffffe
    8000568e:	f98080e7          	jalr	-104(ra) # 80003622 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80005692:	04449703          	lh	a4,68(s1)
    80005696:	4785                	li	a5,1
    80005698:	f4f712e3          	bne	a4,a5,800055dc <sys_open+0x5e>
    8000569c:	f4c42783          	lw	a5,-180(s0)
    800056a0:	dba1                	beqz	a5,800055f0 <sys_open+0x72>
      iunlockput(ip);
    800056a2:	8526                	mv	a0,s1
    800056a4:	ffffe097          	auipc	ra,0xffffe
    800056a8:	1e0080e7          	jalr	480(ra) # 80003884 <iunlockput>
      end_op();
    800056ac:	fffff097          	auipc	ra,0xfffff
    800056b0:	996080e7          	jalr	-1642(ra) # 80004042 <end_op>
      return -1;
    800056b4:	557d                	li	a0,-1
    800056b6:	b76d                	j	80005660 <sys_open+0xe2>
      end_op();
    800056b8:	fffff097          	auipc	ra,0xfffff
    800056bc:	98a080e7          	jalr	-1654(ra) # 80004042 <end_op>
      return -1;
    800056c0:	557d                	li	a0,-1
    800056c2:	bf79                	j	80005660 <sys_open+0xe2>
    iunlockput(ip);
    800056c4:	8526                	mv	a0,s1
    800056c6:	ffffe097          	auipc	ra,0xffffe
    800056ca:	1be080e7          	jalr	446(ra) # 80003884 <iunlockput>
    end_op();
    800056ce:	fffff097          	auipc	ra,0xfffff
    800056d2:	974080e7          	jalr	-1676(ra) # 80004042 <end_op>
    return -1;
    800056d6:	557d                	li	a0,-1
    800056d8:	b761                	j	80005660 <sys_open+0xe2>
      fileclose(f);
    800056da:	854a                	mv	a0,s2
    800056dc:	fffff097          	auipc	ra,0xfffff
    800056e0:	db0080e7          	jalr	-592(ra) # 8000448c <fileclose>
    iunlockput(ip);
    800056e4:	8526                	mv	a0,s1
    800056e6:	ffffe097          	auipc	ra,0xffffe
    800056ea:	19e080e7          	jalr	414(ra) # 80003884 <iunlockput>
    end_op();
    800056ee:	fffff097          	auipc	ra,0xfffff
    800056f2:	954080e7          	jalr	-1708(ra) # 80004042 <end_op>
    return -1;
    800056f6:	557d                	li	a0,-1
    800056f8:	b7a5                	j	80005660 <sys_open+0xe2>
    f->type = FD_DEVICE;
    800056fa:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    800056fe:	04649783          	lh	a5,70(s1)
    80005702:	02f91223          	sh	a5,36(s2)
    80005706:	bf21                	j	8000561e <sys_open+0xa0>
    itrunc(ip);
    80005708:	8526                	mv	a0,s1
    8000570a:	ffffe097          	auipc	ra,0xffffe
    8000570e:	026080e7          	jalr	38(ra) # 80003730 <itrunc>
    80005712:	bf2d                	j	8000564c <sys_open+0xce>

0000000080005714 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005714:	7175                	addi	sp,sp,-144
    80005716:	e506                	sd	ra,136(sp)
    80005718:	e122                	sd	s0,128(sp)
    8000571a:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    8000571c:	fffff097          	auipc	ra,0xfffff
    80005720:	8ac080e7          	jalr	-1876(ra) # 80003fc8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005724:	08000613          	li	a2,128
    80005728:	f7040593          	addi	a1,s0,-144
    8000572c:	4501                	li	a0,0
    8000572e:	ffffd097          	auipc	ra,0xffffd
    80005732:	3d2080e7          	jalr	978(ra) # 80002b00 <argstr>
    80005736:	02054963          	bltz	a0,80005768 <sys_mkdir+0x54>
    8000573a:	4681                	li	a3,0
    8000573c:	4601                	li	a2,0
    8000573e:	4585                	li	a1,1
    80005740:	f7040513          	addi	a0,s0,-144
    80005744:	00000097          	auipc	ra,0x0
    80005748:	806080e7          	jalr	-2042(ra) # 80004f4a <create>
    8000574c:	cd11                	beqz	a0,80005768 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    8000574e:	ffffe097          	auipc	ra,0xffffe
    80005752:	136080e7          	jalr	310(ra) # 80003884 <iunlockput>
  end_op();
    80005756:	fffff097          	auipc	ra,0xfffff
    8000575a:	8ec080e7          	jalr	-1812(ra) # 80004042 <end_op>
  return 0;
    8000575e:	4501                	li	a0,0
}
    80005760:	60aa                	ld	ra,136(sp)
    80005762:	640a                	ld	s0,128(sp)
    80005764:	6149                	addi	sp,sp,144
    80005766:	8082                	ret
    end_op();
    80005768:	fffff097          	auipc	ra,0xfffff
    8000576c:	8da080e7          	jalr	-1830(ra) # 80004042 <end_op>
    return -1;
    80005770:	557d                	li	a0,-1
    80005772:	b7fd                	j	80005760 <sys_mkdir+0x4c>

0000000080005774 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005774:	7135                	addi	sp,sp,-160
    80005776:	ed06                	sd	ra,152(sp)
    80005778:	e922                	sd	s0,144(sp)
    8000577a:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    8000577c:	fffff097          	auipc	ra,0xfffff
    80005780:	84c080e7          	jalr	-1972(ra) # 80003fc8 <begin_op>
  argint(1, &major);
    80005784:	f6c40593          	addi	a1,s0,-148
    80005788:	4505                	li	a0,1
    8000578a:	ffffd097          	auipc	ra,0xffffd
    8000578e:	336080e7          	jalr	822(ra) # 80002ac0 <argint>
  argint(2, &minor);
    80005792:	f6840593          	addi	a1,s0,-152
    80005796:	4509                	li	a0,2
    80005798:	ffffd097          	auipc	ra,0xffffd
    8000579c:	328080e7          	jalr	808(ra) # 80002ac0 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057a0:	08000613          	li	a2,128
    800057a4:	f7040593          	addi	a1,s0,-144
    800057a8:	4501                	li	a0,0
    800057aa:	ffffd097          	auipc	ra,0xffffd
    800057ae:	356080e7          	jalr	854(ra) # 80002b00 <argstr>
    800057b2:	02054b63          	bltz	a0,800057e8 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    800057b6:	f6841683          	lh	a3,-152(s0)
    800057ba:	f6c41603          	lh	a2,-148(s0)
    800057be:	458d                	li	a1,3
    800057c0:	f7040513          	addi	a0,s0,-144
    800057c4:	fffff097          	auipc	ra,0xfffff
    800057c8:	786080e7          	jalr	1926(ra) # 80004f4a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    800057cc:	cd11                	beqz	a0,800057e8 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    800057ce:	ffffe097          	auipc	ra,0xffffe
    800057d2:	0b6080e7          	jalr	182(ra) # 80003884 <iunlockput>
  end_op();
    800057d6:	fffff097          	auipc	ra,0xfffff
    800057da:	86c080e7          	jalr	-1940(ra) # 80004042 <end_op>
  return 0;
    800057de:	4501                	li	a0,0
}
    800057e0:	60ea                	ld	ra,152(sp)
    800057e2:	644a                	ld	s0,144(sp)
    800057e4:	610d                	addi	sp,sp,160
    800057e6:	8082                	ret
    end_op();
    800057e8:	fffff097          	auipc	ra,0xfffff
    800057ec:	85a080e7          	jalr	-1958(ra) # 80004042 <end_op>
    return -1;
    800057f0:	557d                	li	a0,-1
    800057f2:	b7fd                	j	800057e0 <sys_mknod+0x6c>

00000000800057f4 <sys_chdir>:

uint64
sys_chdir(void)
{
    800057f4:	7135                	addi	sp,sp,-160
    800057f6:	ed06                	sd	ra,152(sp)
    800057f8:	e922                	sd	s0,144(sp)
    800057fa:	e526                	sd	s1,136(sp)
    800057fc:	e14a                	sd	s2,128(sp)
    800057fe:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005800:	ffffc097          	auipc	ra,0xffffc
    80005804:	1a6080e7          	jalr	422(ra) # 800019a6 <myproc>
    80005808:	892a                	mv	s2,a0
  
  begin_op();
    8000580a:	ffffe097          	auipc	ra,0xffffe
    8000580e:	7be080e7          	jalr	1982(ra) # 80003fc8 <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005812:	08000613          	li	a2,128
    80005816:	f6040593          	addi	a1,s0,-160
    8000581a:	4501                	li	a0,0
    8000581c:	ffffd097          	auipc	ra,0xffffd
    80005820:	2e4080e7          	jalr	740(ra) # 80002b00 <argstr>
    80005824:	04054b63          	bltz	a0,8000587a <sys_chdir+0x86>
    80005828:	f6040513          	addi	a0,s0,-160
    8000582c:	ffffe097          	auipc	ra,0xffffe
    80005830:	59c080e7          	jalr	1436(ra) # 80003dc8 <namei>
    80005834:	84aa                	mv	s1,a0
    80005836:	c131                	beqz	a0,8000587a <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005838:	ffffe097          	auipc	ra,0xffffe
    8000583c:	dea080e7          	jalr	-534(ra) # 80003622 <ilock>
  if(ip->type != T_DIR){
    80005840:	04449703          	lh	a4,68(s1)
    80005844:	4785                	li	a5,1
    80005846:	04f71063          	bne	a4,a5,80005886 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000584a:	8526                	mv	a0,s1
    8000584c:	ffffe097          	auipc	ra,0xffffe
    80005850:	e98080e7          	jalr	-360(ra) # 800036e4 <iunlock>
  iput(p->cwd);
    80005854:	15093503          	ld	a0,336(s2)
    80005858:	ffffe097          	auipc	ra,0xffffe
    8000585c:	f84080e7          	jalr	-124(ra) # 800037dc <iput>
  end_op();
    80005860:	ffffe097          	auipc	ra,0xffffe
    80005864:	7e2080e7          	jalr	2018(ra) # 80004042 <end_op>
  p->cwd = ip;
    80005868:	14993823          	sd	s1,336(s2)
  return 0;
    8000586c:	4501                	li	a0,0
}
    8000586e:	60ea                	ld	ra,152(sp)
    80005870:	644a                	ld	s0,144(sp)
    80005872:	64aa                	ld	s1,136(sp)
    80005874:	690a                	ld	s2,128(sp)
    80005876:	610d                	addi	sp,sp,160
    80005878:	8082                	ret
    end_op();
    8000587a:	ffffe097          	auipc	ra,0xffffe
    8000587e:	7c8080e7          	jalr	1992(ra) # 80004042 <end_op>
    return -1;
    80005882:	557d                	li	a0,-1
    80005884:	b7ed                	j	8000586e <sys_chdir+0x7a>
    iunlockput(ip);
    80005886:	8526                	mv	a0,s1
    80005888:	ffffe097          	auipc	ra,0xffffe
    8000588c:	ffc080e7          	jalr	-4(ra) # 80003884 <iunlockput>
    end_op();
    80005890:	ffffe097          	auipc	ra,0xffffe
    80005894:	7b2080e7          	jalr	1970(ra) # 80004042 <end_op>
    return -1;
    80005898:	557d                	li	a0,-1
    8000589a:	bfd1                	j	8000586e <sys_chdir+0x7a>

000000008000589c <sys_exec>:

uint64
sys_exec(void)
{
    8000589c:	7121                	addi	sp,sp,-448
    8000589e:	ff06                	sd	ra,440(sp)
    800058a0:	fb22                	sd	s0,432(sp)
    800058a2:	f726                	sd	s1,424(sp)
    800058a4:	f34a                	sd	s2,416(sp)
    800058a6:	ef4e                	sd	s3,408(sp)
    800058a8:	eb52                	sd	s4,400(sp)
    800058aa:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800058ac:	e4840593          	addi	a1,s0,-440
    800058b0:	4505                	li	a0,1
    800058b2:	ffffd097          	auipc	ra,0xffffd
    800058b6:	22e080e7          	jalr	558(ra) # 80002ae0 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800058ba:	08000613          	li	a2,128
    800058be:	f5040593          	addi	a1,s0,-176
    800058c2:	4501                	li	a0,0
    800058c4:	ffffd097          	auipc	ra,0xffffd
    800058c8:	23c080e7          	jalr	572(ra) # 80002b00 <argstr>
    800058cc:	87aa                	mv	a5,a0
    return -1;
    800058ce:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    800058d0:	0c07c263          	bltz	a5,80005994 <sys_exec+0xf8>
  }
  memset(argv, 0, sizeof(argv));
    800058d4:	10000613          	li	a2,256
    800058d8:	4581                	li	a1,0
    800058da:	e5040513          	addi	a0,s0,-432
    800058de:	ffffb097          	auipc	ra,0xffffb
    800058e2:	3f0080e7          	jalr	1008(ra) # 80000cce <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    800058e6:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    800058ea:	89a6                	mv	s3,s1
    800058ec:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    800058ee:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    800058f2:	00391513          	slli	a0,s2,0x3
    800058f6:	e4040593          	addi	a1,s0,-448
    800058fa:	e4843783          	ld	a5,-440(s0)
    800058fe:	953e                	add	a0,a0,a5
    80005900:	ffffd097          	auipc	ra,0xffffd
    80005904:	122080e7          	jalr	290(ra) # 80002a22 <fetchaddr>
    80005908:	02054a63          	bltz	a0,8000593c <sys_exec+0xa0>
      goto bad;
    }
    if(uarg == 0){
    8000590c:	e4043783          	ld	a5,-448(s0)
    80005910:	c3b9                	beqz	a5,80005956 <sys_exec+0xba>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005912:	ffffb097          	auipc	ra,0xffffb
    80005916:	1d0080e7          	jalr	464(ra) # 80000ae2 <kalloc>
    8000591a:	85aa                	mv	a1,a0
    8000591c:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005920:	cd11                	beqz	a0,8000593c <sys_exec+0xa0>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005922:	6605                	lui	a2,0x1
    80005924:	e4043503          	ld	a0,-448(s0)
    80005928:	ffffd097          	auipc	ra,0xffffd
    8000592c:	14c080e7          	jalr	332(ra) # 80002a74 <fetchstr>
    80005930:	00054663          	bltz	a0,8000593c <sys_exec+0xa0>
    if(i >= NELEM(argv)){
    80005934:	0905                	addi	s2,s2,1
    80005936:	09a1                	addi	s3,s3,8
    80005938:	fb491de3          	bne	s2,s4,800058f2 <sys_exec+0x56>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000593c:	f5040913          	addi	s2,s0,-176
    80005940:	6088                	ld	a0,0(s1)
    80005942:	c921                	beqz	a0,80005992 <sys_exec+0xf6>
    kfree(argv[i]);
    80005944:	ffffb097          	auipc	ra,0xffffb
    80005948:	0a0080e7          	jalr	160(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    8000594c:	04a1                	addi	s1,s1,8
    8000594e:	ff2499e3          	bne	s1,s2,80005940 <sys_exec+0xa4>
  return -1;
    80005952:	557d                	li	a0,-1
    80005954:	a081                	j	80005994 <sys_exec+0xf8>
      argv[i] = 0;
    80005956:	0009079b          	sext.w	a5,s2
    8000595a:	078e                	slli	a5,a5,0x3
    8000595c:	fd078793          	addi	a5,a5,-48
    80005960:	97a2                	add	a5,a5,s0
    80005962:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005966:	e5040593          	addi	a1,s0,-432
    8000596a:	f5040513          	addi	a0,s0,-176
    8000596e:	fffff097          	auipc	ra,0xfffff
    80005972:	194080e7          	jalr	404(ra) # 80004b02 <exec>
    80005976:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005978:	f5040993          	addi	s3,s0,-176
    8000597c:	6088                	ld	a0,0(s1)
    8000597e:	c901                	beqz	a0,8000598e <sys_exec+0xf2>
    kfree(argv[i]);
    80005980:	ffffb097          	auipc	ra,0xffffb
    80005984:	064080e7          	jalr	100(ra) # 800009e4 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005988:	04a1                	addi	s1,s1,8
    8000598a:	ff3499e3          	bne	s1,s3,8000597c <sys_exec+0xe0>
  return ret;
    8000598e:	854a                	mv	a0,s2
    80005990:	a011                	j	80005994 <sys_exec+0xf8>
  return -1;
    80005992:	557d                	li	a0,-1
}
    80005994:	70fa                	ld	ra,440(sp)
    80005996:	745a                	ld	s0,432(sp)
    80005998:	74ba                	ld	s1,424(sp)
    8000599a:	791a                	ld	s2,416(sp)
    8000599c:	69fa                	ld	s3,408(sp)
    8000599e:	6a5a                	ld	s4,400(sp)
    800059a0:	6139                	addi	sp,sp,448
    800059a2:	8082                	ret

00000000800059a4 <sys_pipe>:

uint64
sys_pipe(void)
{
    800059a4:	7139                	addi	sp,sp,-64
    800059a6:	fc06                	sd	ra,56(sp)
    800059a8:	f822                	sd	s0,48(sp)
    800059aa:	f426                	sd	s1,40(sp)
    800059ac:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800059ae:	ffffc097          	auipc	ra,0xffffc
    800059b2:	ff8080e7          	jalr	-8(ra) # 800019a6 <myproc>
    800059b6:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800059b8:	fd840593          	addi	a1,s0,-40
    800059bc:	4501                	li	a0,0
    800059be:	ffffd097          	auipc	ra,0xffffd
    800059c2:	122080e7          	jalr	290(ra) # 80002ae0 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800059c6:	fc840593          	addi	a1,s0,-56
    800059ca:	fd040513          	addi	a0,s0,-48
    800059ce:	fffff097          	auipc	ra,0xfffff
    800059d2:	dea080e7          	jalr	-534(ra) # 800047b8 <pipealloc>
    return -1;
    800059d6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800059d8:	0c054463          	bltz	a0,80005aa0 <sys_pipe+0xfc>
  fd0 = -1;
    800059dc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    800059e0:	fd043503          	ld	a0,-48(s0)
    800059e4:	fffff097          	auipc	ra,0xfffff
    800059e8:	524080e7          	jalr	1316(ra) # 80004f08 <fdalloc>
    800059ec:	fca42223          	sw	a0,-60(s0)
    800059f0:	08054b63          	bltz	a0,80005a86 <sys_pipe+0xe2>
    800059f4:	fc843503          	ld	a0,-56(s0)
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	510080e7          	jalr	1296(ra) # 80004f08 <fdalloc>
    80005a00:	fca42023          	sw	a0,-64(s0)
    80005a04:	06054863          	bltz	a0,80005a74 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a08:	4691                	li	a3,4
    80005a0a:	fc440613          	addi	a2,s0,-60
    80005a0e:	fd843583          	ld	a1,-40(s0)
    80005a12:	68a8                	ld	a0,80(s1)
    80005a14:	ffffc097          	auipc	ra,0xffffc
    80005a18:	c52080e7          	jalr	-942(ra) # 80001666 <copyout>
    80005a1c:	02054063          	bltz	a0,80005a3c <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005a20:	4691                	li	a3,4
    80005a22:	fc040613          	addi	a2,s0,-64
    80005a26:	fd843583          	ld	a1,-40(s0)
    80005a2a:	0591                	addi	a1,a1,4
    80005a2c:	68a8                	ld	a0,80(s1)
    80005a2e:	ffffc097          	auipc	ra,0xffffc
    80005a32:	c38080e7          	jalr	-968(ra) # 80001666 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005a36:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005a38:	06055463          	bgez	a0,80005aa0 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005a3c:	fc442783          	lw	a5,-60(s0)
    80005a40:	07e9                	addi	a5,a5,26
    80005a42:	078e                	slli	a5,a5,0x3
    80005a44:	97a6                	add	a5,a5,s1
    80005a46:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005a4a:	fc042783          	lw	a5,-64(s0)
    80005a4e:	07e9                	addi	a5,a5,26
    80005a50:	078e                	slli	a5,a5,0x3
    80005a52:	94be                	add	s1,s1,a5
    80005a54:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005a58:	fd043503          	ld	a0,-48(s0)
    80005a5c:	fffff097          	auipc	ra,0xfffff
    80005a60:	a30080e7          	jalr	-1488(ra) # 8000448c <fileclose>
    fileclose(wf);
    80005a64:	fc843503          	ld	a0,-56(s0)
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	a24080e7          	jalr	-1500(ra) # 8000448c <fileclose>
    return -1;
    80005a70:	57fd                	li	a5,-1
    80005a72:	a03d                	j	80005aa0 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005a74:	fc442783          	lw	a5,-60(s0)
    80005a78:	0007c763          	bltz	a5,80005a86 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005a7c:	07e9                	addi	a5,a5,26
    80005a7e:	078e                	slli	a5,a5,0x3
    80005a80:	97a6                	add	a5,a5,s1
    80005a82:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005a86:	fd043503          	ld	a0,-48(s0)
    80005a8a:	fffff097          	auipc	ra,0xfffff
    80005a8e:	a02080e7          	jalr	-1534(ra) # 8000448c <fileclose>
    fileclose(wf);
    80005a92:	fc843503          	ld	a0,-56(s0)
    80005a96:	fffff097          	auipc	ra,0xfffff
    80005a9a:	9f6080e7          	jalr	-1546(ra) # 8000448c <fileclose>
    return -1;
    80005a9e:	57fd                	li	a5,-1
}
    80005aa0:	853e                	mv	a0,a5
    80005aa2:	70e2                	ld	ra,56(sp)
    80005aa4:	7442                	ld	s0,48(sp)
    80005aa6:	74a2                	ld	s1,40(sp)
    80005aa8:	6121                	addi	sp,sp,64
    80005aaa:	8082                	ret
    80005aac:	0000                	unimp
	...

0000000080005ab0 <kernelvec>:
    80005ab0:	7111                	addi	sp,sp,-256
    80005ab2:	e006                	sd	ra,0(sp)
    80005ab4:	e40a                	sd	sp,8(sp)
    80005ab6:	e80e                	sd	gp,16(sp)
    80005ab8:	ec12                	sd	tp,24(sp)
    80005aba:	f016                	sd	t0,32(sp)
    80005abc:	f41a                	sd	t1,40(sp)
    80005abe:	f81e                	sd	t2,48(sp)
    80005ac0:	fc22                	sd	s0,56(sp)
    80005ac2:	e0a6                	sd	s1,64(sp)
    80005ac4:	e4aa                	sd	a0,72(sp)
    80005ac6:	e8ae                	sd	a1,80(sp)
    80005ac8:	ecb2                	sd	a2,88(sp)
    80005aca:	f0b6                	sd	a3,96(sp)
    80005acc:	f4ba                	sd	a4,104(sp)
    80005ace:	f8be                	sd	a5,112(sp)
    80005ad0:	fcc2                	sd	a6,120(sp)
    80005ad2:	e146                	sd	a7,128(sp)
    80005ad4:	e54a                	sd	s2,136(sp)
    80005ad6:	e94e                	sd	s3,144(sp)
    80005ad8:	ed52                	sd	s4,152(sp)
    80005ada:	f156                	sd	s5,160(sp)
    80005adc:	f55a                	sd	s6,168(sp)
    80005ade:	f95e                	sd	s7,176(sp)
    80005ae0:	fd62                	sd	s8,184(sp)
    80005ae2:	e1e6                	sd	s9,192(sp)
    80005ae4:	e5ea                	sd	s10,200(sp)
    80005ae6:	e9ee                	sd	s11,208(sp)
    80005ae8:	edf2                	sd	t3,216(sp)
    80005aea:	f1f6                	sd	t4,224(sp)
    80005aec:	f5fa                	sd	t5,232(sp)
    80005aee:	f9fe                	sd	t6,240(sp)
    80005af0:	dfffc0ef          	jal	ra,800028ee <kerneltrap>
    80005af4:	6082                	ld	ra,0(sp)
    80005af6:	6122                	ld	sp,8(sp)
    80005af8:	61c2                	ld	gp,16(sp)
    80005afa:	7282                	ld	t0,32(sp)
    80005afc:	7322                	ld	t1,40(sp)
    80005afe:	73c2                	ld	t2,48(sp)
    80005b00:	7462                	ld	s0,56(sp)
    80005b02:	6486                	ld	s1,64(sp)
    80005b04:	6526                	ld	a0,72(sp)
    80005b06:	65c6                	ld	a1,80(sp)
    80005b08:	6666                	ld	a2,88(sp)
    80005b0a:	7686                	ld	a3,96(sp)
    80005b0c:	7726                	ld	a4,104(sp)
    80005b0e:	77c6                	ld	a5,112(sp)
    80005b10:	7866                	ld	a6,120(sp)
    80005b12:	688a                	ld	a7,128(sp)
    80005b14:	692a                	ld	s2,136(sp)
    80005b16:	69ca                	ld	s3,144(sp)
    80005b18:	6a6a                	ld	s4,152(sp)
    80005b1a:	7a8a                	ld	s5,160(sp)
    80005b1c:	7b2a                	ld	s6,168(sp)
    80005b1e:	7bca                	ld	s7,176(sp)
    80005b20:	7c6a                	ld	s8,184(sp)
    80005b22:	6c8e                	ld	s9,192(sp)
    80005b24:	6d2e                	ld	s10,200(sp)
    80005b26:	6dce                	ld	s11,208(sp)
    80005b28:	6e6e                	ld	t3,216(sp)
    80005b2a:	7e8e                	ld	t4,224(sp)
    80005b2c:	7f2e                	ld	t5,232(sp)
    80005b2e:	7fce                	ld	t6,240(sp)
    80005b30:	6111                	addi	sp,sp,256
    80005b32:	10200073          	sret
    80005b36:	00000013          	nop
    80005b3a:	00000013          	nop
    80005b3e:	0001                	nop

0000000080005b40 <timervec>:
    80005b40:	34051573          	csrrw	a0,mscratch,a0
    80005b44:	e10c                	sd	a1,0(a0)
    80005b46:	e510                	sd	a2,8(a0)
    80005b48:	e914                	sd	a3,16(a0)
    80005b4a:	6d0c                	ld	a1,24(a0)
    80005b4c:	7110                	ld	a2,32(a0)
    80005b4e:	6194                	ld	a3,0(a1)
    80005b50:	96b2                	add	a3,a3,a2
    80005b52:	e194                	sd	a3,0(a1)
    80005b54:	4589                	li	a1,2
    80005b56:	14459073          	csrw	sip,a1
    80005b5a:	6914                	ld	a3,16(a0)
    80005b5c:	6510                	ld	a2,8(a0)
    80005b5e:	610c                	ld	a1,0(a0)
    80005b60:	34051573          	csrrw	a0,mscratch,a0
    80005b64:	30200073          	mret
	...

0000000080005b6a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005b6a:	1141                	addi	sp,sp,-16
    80005b6c:	e422                	sd	s0,8(sp)
    80005b6e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005b70:	0c0007b7          	lui	a5,0xc000
    80005b74:	4705                	li	a4,1
    80005b76:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005b78:	c3d8                	sw	a4,4(a5)
}
    80005b7a:	6422                	ld	s0,8(sp)
    80005b7c:	0141                	addi	sp,sp,16
    80005b7e:	8082                	ret

0000000080005b80 <plicinithart>:

void
plicinithart(void)
{
    80005b80:	1141                	addi	sp,sp,-16
    80005b82:	e406                	sd	ra,8(sp)
    80005b84:	e022                	sd	s0,0(sp)
    80005b86:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005b88:	ffffc097          	auipc	ra,0xffffc
    80005b8c:	df2080e7          	jalr	-526(ra) # 8000197a <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005b90:	0085171b          	slliw	a4,a0,0x8
    80005b94:	0c0027b7          	lui	a5,0xc002
    80005b98:	97ba                	add	a5,a5,a4
    80005b9a:	40200713          	li	a4,1026
    80005b9e:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ba2:	00d5151b          	slliw	a0,a0,0xd
    80005ba6:	0c2017b7          	lui	a5,0xc201
    80005baa:	97aa                	add	a5,a5,a0
    80005bac:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005bb0:	60a2                	ld	ra,8(sp)
    80005bb2:	6402                	ld	s0,0(sp)
    80005bb4:	0141                	addi	sp,sp,16
    80005bb6:	8082                	ret

0000000080005bb8 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005bb8:	1141                	addi	sp,sp,-16
    80005bba:	e406                	sd	ra,8(sp)
    80005bbc:	e022                	sd	s0,0(sp)
    80005bbe:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005bc0:	ffffc097          	auipc	ra,0xffffc
    80005bc4:	dba080e7          	jalr	-582(ra) # 8000197a <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005bc8:	00d5151b          	slliw	a0,a0,0xd
    80005bcc:	0c2017b7          	lui	a5,0xc201
    80005bd0:	97aa                	add	a5,a5,a0
  return irq;
}
    80005bd2:	43c8                	lw	a0,4(a5)
    80005bd4:	60a2                	ld	ra,8(sp)
    80005bd6:	6402                	ld	s0,0(sp)
    80005bd8:	0141                	addi	sp,sp,16
    80005bda:	8082                	ret

0000000080005bdc <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005bdc:	1101                	addi	sp,sp,-32
    80005bde:	ec06                	sd	ra,24(sp)
    80005be0:	e822                	sd	s0,16(sp)
    80005be2:	e426                	sd	s1,8(sp)
    80005be4:	1000                	addi	s0,sp,32
    80005be6:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005be8:	ffffc097          	auipc	ra,0xffffc
    80005bec:	d92080e7          	jalr	-622(ra) # 8000197a <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005bf0:	00d5151b          	slliw	a0,a0,0xd
    80005bf4:	0c2017b7          	lui	a5,0xc201
    80005bf8:	97aa                	add	a5,a5,a0
    80005bfa:	c3c4                	sw	s1,4(a5)
}
    80005bfc:	60e2                	ld	ra,24(sp)
    80005bfe:	6442                	ld	s0,16(sp)
    80005c00:	64a2                	ld	s1,8(sp)
    80005c02:	6105                	addi	sp,sp,32
    80005c04:	8082                	ret

0000000080005c06 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005c06:	1141                	addi	sp,sp,-16
    80005c08:	e406                	sd	ra,8(sp)
    80005c0a:	e022                	sd	s0,0(sp)
    80005c0c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005c0e:	479d                	li	a5,7
    80005c10:	04a7cc63          	blt	a5,a0,80005c68 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005c14:	0001c797          	auipc	a5,0x1c
    80005c18:	fec78793          	addi	a5,a5,-20 # 80021c00 <disk>
    80005c1c:	97aa                	add	a5,a5,a0
    80005c1e:	0187c783          	lbu	a5,24(a5)
    80005c22:	ebb9                	bnez	a5,80005c78 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005c24:	00451693          	slli	a3,a0,0x4
    80005c28:	0001c797          	auipc	a5,0x1c
    80005c2c:	fd878793          	addi	a5,a5,-40 # 80021c00 <disk>
    80005c30:	6398                	ld	a4,0(a5)
    80005c32:	9736                	add	a4,a4,a3
    80005c34:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005c38:	6398                	ld	a4,0(a5)
    80005c3a:	9736                	add	a4,a4,a3
    80005c3c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005c40:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005c44:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005c48:	97aa                	add	a5,a5,a0
    80005c4a:	4705                	li	a4,1
    80005c4c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005c50:	0001c517          	auipc	a0,0x1c
    80005c54:	fc850513          	addi	a0,a0,-56 # 80021c18 <disk+0x18>
    80005c58:	ffffc097          	auipc	ra,0xffffc
    80005c5c:	45a080e7          	jalr	1114(ra) # 800020b2 <wakeup>
}
    80005c60:	60a2                	ld	ra,8(sp)
    80005c62:	6402                	ld	s0,0(sp)
    80005c64:	0141                	addi	sp,sp,16
    80005c66:	8082                	ret
    panic("free_desc 1");
    80005c68:	00003517          	auipc	a0,0x3
    80005c6c:	ad850513          	addi	a0,a0,-1320 # 80008740 <syscalls+0x2f0>
    80005c70:	ffffb097          	auipc	ra,0xffffb
    80005c74:	8cc080e7          	jalr	-1844(ra) # 8000053c <panic>
    panic("free_desc 2");
    80005c78:	00003517          	auipc	a0,0x3
    80005c7c:	ad850513          	addi	a0,a0,-1320 # 80008750 <syscalls+0x300>
    80005c80:	ffffb097          	auipc	ra,0xffffb
    80005c84:	8bc080e7          	jalr	-1860(ra) # 8000053c <panic>

0000000080005c88 <virtio_disk_init>:
{
    80005c88:	1101                	addi	sp,sp,-32
    80005c8a:	ec06                	sd	ra,24(sp)
    80005c8c:	e822                	sd	s0,16(sp)
    80005c8e:	e426                	sd	s1,8(sp)
    80005c90:	e04a                	sd	s2,0(sp)
    80005c92:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005c94:	00003597          	auipc	a1,0x3
    80005c98:	acc58593          	addi	a1,a1,-1332 # 80008760 <syscalls+0x310>
    80005c9c:	0001c517          	auipc	a0,0x1c
    80005ca0:	08c50513          	addi	a0,a0,140 # 80021d28 <disk+0x128>
    80005ca4:	ffffb097          	auipc	ra,0xffffb
    80005ca8:	e9e080e7          	jalr	-354(ra) # 80000b42 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cac:	100017b7          	lui	a5,0x10001
    80005cb0:	4398                	lw	a4,0(a5)
    80005cb2:	2701                	sext.w	a4,a4
    80005cb4:	747277b7          	lui	a5,0x74727
    80005cb8:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005cbc:	14f71b63          	bne	a4,a5,80005e12 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005cc0:	100017b7          	lui	a5,0x10001
    80005cc4:	43dc                	lw	a5,4(a5)
    80005cc6:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005cc8:	4709                	li	a4,2
    80005cca:	14e79463          	bne	a5,a4,80005e12 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005cce:	100017b7          	lui	a5,0x10001
    80005cd2:	479c                	lw	a5,8(a5)
    80005cd4:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005cd6:	12e79e63          	bne	a5,a4,80005e12 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    80005cda:	100017b7          	lui	a5,0x10001
    80005cde:	47d8                	lw	a4,12(a5)
    80005ce0:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005ce2:	554d47b7          	lui	a5,0x554d4
    80005ce6:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    80005cea:	12f71463          	bne	a4,a5,80005e12 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cee:	100017b7          	lui	a5,0x10001
    80005cf2:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cf6:	4705                	li	a4,1
    80005cf8:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005cfa:	470d                	li	a4,3
    80005cfc:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    80005cfe:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80005d00:	c7ffe6b7          	lui	a3,0xc7ffe
    80005d04:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdca1f>
    80005d08:	8f75                	and	a4,a4,a3
    80005d0a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005d0c:	472d                	li	a4,11
    80005d0e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80005d10:	5bbc                	lw	a5,112(a5)
    80005d12:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80005d16:	8ba1                	andi	a5,a5,8
    80005d18:	10078563          	beqz	a5,80005e22 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    80005d1c:	100017b7          	lui	a5,0x10001
    80005d20:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80005d24:	43fc                	lw	a5,68(a5)
    80005d26:	2781                	sext.w	a5,a5
    80005d28:	10079563          	bnez	a5,80005e32 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    80005d2c:	100017b7          	lui	a5,0x10001
    80005d30:	5bdc                	lw	a5,52(a5)
    80005d32:	2781                	sext.w	a5,a5
  if(max == 0)
    80005d34:	10078763          	beqz	a5,80005e42 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80005d38:	471d                	li	a4,7
    80005d3a:	10f77c63          	bgeu	a4,a5,80005e52 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    80005d3e:	ffffb097          	auipc	ra,0xffffb
    80005d42:	da4080e7          	jalr	-604(ra) # 80000ae2 <kalloc>
    80005d46:	0001c497          	auipc	s1,0x1c
    80005d4a:	eba48493          	addi	s1,s1,-326 # 80021c00 <disk>
    80005d4e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    80005d50:	ffffb097          	auipc	ra,0xffffb
    80005d54:	d92080e7          	jalr	-622(ra) # 80000ae2 <kalloc>
    80005d58:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    80005d5a:	ffffb097          	auipc	ra,0xffffb
    80005d5e:	d88080e7          	jalr	-632(ra) # 80000ae2 <kalloc>
    80005d62:	87aa                	mv	a5,a0
    80005d64:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005d66:	6088                	ld	a0,0(s1)
    80005d68:	cd6d                	beqz	a0,80005e62 <virtio_disk_init+0x1da>
    80005d6a:	0001c717          	auipc	a4,0x1c
    80005d6e:	e9e73703          	ld	a4,-354(a4) # 80021c08 <disk+0x8>
    80005d72:	cb65                	beqz	a4,80005e62 <virtio_disk_init+0x1da>
    80005d74:	c7fd                	beqz	a5,80005e62 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    80005d76:	6605                	lui	a2,0x1
    80005d78:	4581                	li	a1,0
    80005d7a:	ffffb097          	auipc	ra,0xffffb
    80005d7e:	f54080e7          	jalr	-172(ra) # 80000cce <memset>
  memset(disk.avail, 0, PGSIZE);
    80005d82:	0001c497          	auipc	s1,0x1c
    80005d86:	e7e48493          	addi	s1,s1,-386 # 80021c00 <disk>
    80005d8a:	6605                	lui	a2,0x1
    80005d8c:	4581                	li	a1,0
    80005d8e:	6488                	ld	a0,8(s1)
    80005d90:	ffffb097          	auipc	ra,0xffffb
    80005d94:	f3e080e7          	jalr	-194(ra) # 80000cce <memset>
  memset(disk.used, 0, PGSIZE);
    80005d98:	6605                	lui	a2,0x1
    80005d9a:	4581                	li	a1,0
    80005d9c:	6888                	ld	a0,16(s1)
    80005d9e:	ffffb097          	auipc	ra,0xffffb
    80005da2:	f30080e7          	jalr	-208(ra) # 80000cce <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    80005da6:	100017b7          	lui	a5,0x10001
    80005daa:	4721                	li	a4,8
    80005dac:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005dae:	4098                	lw	a4,0(s1)
    80005db0:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80005db4:	40d8                	lw	a4,4(s1)
    80005db6:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005dba:	6498                	ld	a4,8(s1)
    80005dbc:	0007069b          	sext.w	a3,a4
    80005dc0:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005dc4:	9701                	srai	a4,a4,0x20
    80005dc6:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005dca:	6898                	ld	a4,16(s1)
    80005dcc:	0007069b          	sext.w	a3,a4
    80005dd0:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80005dd4:	9701                	srai	a4,a4,0x20
    80005dd6:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005dda:	4705                	li	a4,1
    80005ddc:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    80005dde:	00e48c23          	sb	a4,24(s1)
    80005de2:	00e48ca3          	sb	a4,25(s1)
    80005de6:	00e48d23          	sb	a4,26(s1)
    80005dea:	00e48da3          	sb	a4,27(s1)
    80005dee:	00e48e23          	sb	a4,28(s1)
    80005df2:	00e48ea3          	sb	a4,29(s1)
    80005df6:	00e48f23          	sb	a4,30(s1)
    80005dfa:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    80005dfe:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80005e02:	0727a823          	sw	s2,112(a5)
}
    80005e06:	60e2                	ld	ra,24(sp)
    80005e08:	6442                	ld	s0,16(sp)
    80005e0a:	64a2                	ld	s1,8(sp)
    80005e0c:	6902                	ld	s2,0(sp)
    80005e0e:	6105                	addi	sp,sp,32
    80005e10:	8082                	ret
    panic("could not find virtio disk");
    80005e12:	00003517          	auipc	a0,0x3
    80005e16:	95e50513          	addi	a0,a0,-1698 # 80008770 <syscalls+0x320>
    80005e1a:	ffffa097          	auipc	ra,0xffffa
    80005e1e:	722080e7          	jalr	1826(ra) # 8000053c <panic>
    panic("virtio disk FEATURES_OK unset");
    80005e22:	00003517          	auipc	a0,0x3
    80005e26:	96e50513          	addi	a0,a0,-1682 # 80008790 <syscalls+0x340>
    80005e2a:	ffffa097          	auipc	ra,0xffffa
    80005e2e:	712080e7          	jalr	1810(ra) # 8000053c <panic>
    panic("virtio disk should not be ready");
    80005e32:	00003517          	auipc	a0,0x3
    80005e36:	97e50513          	addi	a0,a0,-1666 # 800087b0 <syscalls+0x360>
    80005e3a:	ffffa097          	auipc	ra,0xffffa
    80005e3e:	702080e7          	jalr	1794(ra) # 8000053c <panic>
    panic("virtio disk has no queue 0");
    80005e42:	00003517          	auipc	a0,0x3
    80005e46:	98e50513          	addi	a0,a0,-1650 # 800087d0 <syscalls+0x380>
    80005e4a:	ffffa097          	auipc	ra,0xffffa
    80005e4e:	6f2080e7          	jalr	1778(ra) # 8000053c <panic>
    panic("virtio disk max queue too short");
    80005e52:	00003517          	auipc	a0,0x3
    80005e56:	99e50513          	addi	a0,a0,-1634 # 800087f0 <syscalls+0x3a0>
    80005e5a:	ffffa097          	auipc	ra,0xffffa
    80005e5e:	6e2080e7          	jalr	1762(ra) # 8000053c <panic>
    panic("virtio disk kalloc");
    80005e62:	00003517          	auipc	a0,0x3
    80005e66:	9ae50513          	addi	a0,a0,-1618 # 80008810 <syscalls+0x3c0>
    80005e6a:	ffffa097          	auipc	ra,0xffffa
    80005e6e:	6d2080e7          	jalr	1746(ra) # 8000053c <panic>

0000000080005e72 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005e72:	7159                	addi	sp,sp,-112
    80005e74:	f486                	sd	ra,104(sp)
    80005e76:	f0a2                	sd	s0,96(sp)
    80005e78:	eca6                	sd	s1,88(sp)
    80005e7a:	e8ca                	sd	s2,80(sp)
    80005e7c:	e4ce                	sd	s3,72(sp)
    80005e7e:	e0d2                	sd	s4,64(sp)
    80005e80:	fc56                	sd	s5,56(sp)
    80005e82:	f85a                	sd	s6,48(sp)
    80005e84:	f45e                	sd	s7,40(sp)
    80005e86:	f062                	sd	s8,32(sp)
    80005e88:	ec66                	sd	s9,24(sp)
    80005e8a:	e86a                	sd	s10,16(sp)
    80005e8c:	1880                	addi	s0,sp,112
    80005e8e:	8a2a                	mv	s4,a0
    80005e90:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    80005e92:	00c52c83          	lw	s9,12(a0)
    80005e96:	001c9c9b          	slliw	s9,s9,0x1
    80005e9a:	1c82                	slli	s9,s9,0x20
    80005e9c:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    80005ea0:	0001c517          	auipc	a0,0x1c
    80005ea4:	e8850513          	addi	a0,a0,-376 # 80021d28 <disk+0x128>
    80005ea8:	ffffb097          	auipc	ra,0xffffb
    80005eac:	d2a080e7          	jalr	-726(ra) # 80000bd2 <acquire>
  for(int i = 0; i < 3; i++){
    80005eb0:	4901                	li	s2,0
  for(int i = 0; i < NUM; i++){
    80005eb2:	44a1                	li	s1,8
      disk.free[i] = 0;
    80005eb4:	0001cb17          	auipc	s6,0x1c
    80005eb8:	d4cb0b13          	addi	s6,s6,-692 # 80021c00 <disk>
  for(int i = 0; i < 3; i++){
    80005ebc:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005ebe:	0001cc17          	auipc	s8,0x1c
    80005ec2:	e6ac0c13          	addi	s8,s8,-406 # 80021d28 <disk+0x128>
    80005ec6:	a095                	j	80005f2a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    80005ec8:	00fb0733          	add	a4,s6,a5
    80005ecc:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80005ed0:	c11c                	sw	a5,0(a0)
    if(idx[i] < 0){
    80005ed2:	0207c563          	bltz	a5,80005efc <virtio_disk_rw+0x8a>
  for(int i = 0; i < 3; i++){
    80005ed6:	2605                	addiw	a2,a2,1 # 1001 <_entry-0x7fffefff>
    80005ed8:	0591                	addi	a1,a1,4
    80005eda:	05560d63          	beq	a2,s5,80005f34 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80005ede:	852e                	mv	a0,a1
  for(int i = 0; i < NUM; i++){
    80005ee0:	0001c717          	auipc	a4,0x1c
    80005ee4:	d2070713          	addi	a4,a4,-736 # 80021c00 <disk>
    80005ee8:	87ca                	mv	a5,s2
    if(disk.free[i]){
    80005eea:	01874683          	lbu	a3,24(a4)
    80005eee:	fee9                	bnez	a3,80005ec8 <virtio_disk_rw+0x56>
  for(int i = 0; i < NUM; i++){
    80005ef0:	2785                	addiw	a5,a5,1
    80005ef2:	0705                	addi	a4,a4,1
    80005ef4:	fe979be3          	bne	a5,s1,80005eea <virtio_disk_rw+0x78>
    idx[i] = alloc_desc();
    80005ef8:	57fd                	li	a5,-1
    80005efa:	c11c                	sw	a5,0(a0)
      for(int j = 0; j < i; j++)
    80005efc:	00c05e63          	blez	a2,80005f18 <virtio_disk_rw+0xa6>
    80005f00:	060a                	slli	a2,a2,0x2
    80005f02:	01360d33          	add	s10,a2,s3
        free_desc(idx[j]);
    80005f06:	0009a503          	lw	a0,0(s3)
    80005f0a:	00000097          	auipc	ra,0x0
    80005f0e:	cfc080e7          	jalr	-772(ra) # 80005c06 <free_desc>
      for(int j = 0; j < i; j++)
    80005f12:	0991                	addi	s3,s3,4
    80005f14:	ffa999e3          	bne	s3,s10,80005f06 <virtio_disk_rw+0x94>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005f18:	85e2                	mv	a1,s8
    80005f1a:	0001c517          	auipc	a0,0x1c
    80005f1e:	cfe50513          	addi	a0,a0,-770 # 80021c18 <disk+0x18>
    80005f22:	ffffc097          	auipc	ra,0xffffc
    80005f26:	12c080e7          	jalr	300(ra) # 8000204e <sleep>
  for(int i = 0; i < 3; i++){
    80005f2a:	f9040993          	addi	s3,s0,-112
{
    80005f2e:	85ce                	mv	a1,s3
  for(int i = 0; i < 3; i++){
    80005f30:	864a                	mv	a2,s2
    80005f32:	b775                	j	80005ede <virtio_disk_rw+0x6c>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f34:	f9042503          	lw	a0,-112(s0)
    80005f38:	00a50713          	addi	a4,a0,10
    80005f3c:	0712                	slli	a4,a4,0x4

  if(write)
    80005f3e:	0001c797          	auipc	a5,0x1c
    80005f42:	cc278793          	addi	a5,a5,-830 # 80021c00 <disk>
    80005f46:	00e786b3          	add	a3,a5,a4
    80005f4a:	01703633          	snez	a2,s7
    80005f4e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005f50:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    80005f54:	0196b823          	sd	s9,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    80005f58:	f6070613          	addi	a2,a4,-160
    80005f5c:	6394                	ld	a3,0(a5)
    80005f5e:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80005f60:	00870593          	addi	a1,a4,8
    80005f64:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    80005f66:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    80005f68:	0007b803          	ld	a6,0(a5)
    80005f6c:	9642                	add	a2,a2,a6
    80005f6e:	46c1                	li	a3,16
    80005f70:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005f72:	4585                	li	a1,1
    80005f74:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    80005f78:	f9442683          	lw	a3,-108(s0)
    80005f7c:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    80005f80:	0692                	slli	a3,a3,0x4
    80005f82:	9836                	add	a6,a6,a3
    80005f84:	058a0613          	addi	a2,s4,88
    80005f88:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    80005f8c:	0007b803          	ld	a6,0(a5)
    80005f90:	96c2                	add	a3,a3,a6
    80005f92:	40000613          	li	a2,1024
    80005f96:	c690                	sw	a2,8(a3)
  if(write)
    80005f98:	001bb613          	seqz	a2,s7
    80005f9c:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    80005fa0:	00166613          	ori	a2,a2,1
    80005fa4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    80005fa8:	f9842603          	lw	a2,-104(s0)
    80005fac:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80005fb0:	00250693          	addi	a3,a0,2
    80005fb4:	0692                	slli	a3,a3,0x4
    80005fb6:	96be                	add	a3,a3,a5
    80005fb8:	58fd                	li	a7,-1
    80005fba:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    80005fbe:	0612                	slli	a2,a2,0x4
    80005fc0:	9832                	add	a6,a6,a2
    80005fc2:	f9070713          	addi	a4,a4,-112
    80005fc6:	973e                	add	a4,a4,a5
    80005fc8:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    80005fcc:	6398                	ld	a4,0(a5)
    80005fce:	9732                	add	a4,a4,a2
    80005fd0:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005fd2:	4609                	li	a2,2
    80005fd4:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80005fd8:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005fdc:	00ba2223          	sw	a1,4(s4)
  disk.info[idx[0]].b = b;
    80005fe0:	0146b423          	sd	s4,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005fe4:	6794                	ld	a3,8(a5)
    80005fe6:	0026d703          	lhu	a4,2(a3)
    80005fea:	8b1d                	andi	a4,a4,7
    80005fec:	0706                	slli	a4,a4,0x1
    80005fee:	96ba                	add	a3,a3,a4
    80005ff0:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005ff4:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005ff8:	6798                	ld	a4,8(a5)
    80005ffa:	00275783          	lhu	a5,2(a4)
    80005ffe:	2785                	addiw	a5,a5,1
    80006000:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006004:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006008:	100017b7          	lui	a5,0x10001
    8000600c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006010:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    80006014:	0001c917          	auipc	s2,0x1c
    80006018:	d1490913          	addi	s2,s2,-748 # 80021d28 <disk+0x128>
  while(b->disk == 1) {
    8000601c:	4485                	li	s1,1
    8000601e:	00b79c63          	bne	a5,a1,80006036 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006022:	85ca                	mv	a1,s2
    80006024:	8552                	mv	a0,s4
    80006026:	ffffc097          	auipc	ra,0xffffc
    8000602a:	028080e7          	jalr	40(ra) # 8000204e <sleep>
  while(b->disk == 1) {
    8000602e:	004a2783          	lw	a5,4(s4)
    80006032:	fe9788e3          	beq	a5,s1,80006022 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006036:	f9042903          	lw	s2,-112(s0)
    8000603a:	00290713          	addi	a4,s2,2
    8000603e:	0712                	slli	a4,a4,0x4
    80006040:	0001c797          	auipc	a5,0x1c
    80006044:	bc078793          	addi	a5,a5,-1088 # 80021c00 <disk>
    80006048:	97ba                	add	a5,a5,a4
    8000604a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000604e:	0001c997          	auipc	s3,0x1c
    80006052:	bb298993          	addi	s3,s3,-1102 # 80021c00 <disk>
    80006056:	00491713          	slli	a4,s2,0x4
    8000605a:	0009b783          	ld	a5,0(s3)
    8000605e:	97ba                	add	a5,a5,a4
    80006060:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    80006064:	854a                	mv	a0,s2
    80006066:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    8000606a:	00000097          	auipc	ra,0x0
    8000606e:	b9c080e7          	jalr	-1124(ra) # 80005c06 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    80006072:	8885                	andi	s1,s1,1
    80006074:	f0ed                	bnez	s1,80006056 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    80006076:	0001c517          	auipc	a0,0x1c
    8000607a:	cb250513          	addi	a0,a0,-846 # 80021d28 <disk+0x128>
    8000607e:	ffffb097          	auipc	ra,0xffffb
    80006082:	c08080e7          	jalr	-1016(ra) # 80000c86 <release>
}
    80006086:	70a6                	ld	ra,104(sp)
    80006088:	7406                	ld	s0,96(sp)
    8000608a:	64e6                	ld	s1,88(sp)
    8000608c:	6946                	ld	s2,80(sp)
    8000608e:	69a6                	ld	s3,72(sp)
    80006090:	6a06                	ld	s4,64(sp)
    80006092:	7ae2                	ld	s5,56(sp)
    80006094:	7b42                	ld	s6,48(sp)
    80006096:	7ba2                	ld	s7,40(sp)
    80006098:	7c02                	ld	s8,32(sp)
    8000609a:	6ce2                	ld	s9,24(sp)
    8000609c:	6d42                	ld	s10,16(sp)
    8000609e:	6165                	addi	sp,sp,112
    800060a0:	8082                	ret

00000000800060a2 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800060a2:	1101                	addi	sp,sp,-32
    800060a4:	ec06                	sd	ra,24(sp)
    800060a6:	e822                	sd	s0,16(sp)
    800060a8:	e426                	sd	s1,8(sp)
    800060aa:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800060ac:	0001c497          	auipc	s1,0x1c
    800060b0:	b5448493          	addi	s1,s1,-1196 # 80021c00 <disk>
    800060b4:	0001c517          	auipc	a0,0x1c
    800060b8:	c7450513          	addi	a0,a0,-908 # 80021d28 <disk+0x128>
    800060bc:	ffffb097          	auipc	ra,0xffffb
    800060c0:	b16080e7          	jalr	-1258(ra) # 80000bd2 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    800060c4:	10001737          	lui	a4,0x10001
    800060c8:	533c                	lw	a5,96(a4)
    800060ca:	8b8d                	andi	a5,a5,3
    800060cc:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    800060ce:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    800060d2:	689c                	ld	a5,16(s1)
    800060d4:	0204d703          	lhu	a4,32(s1)
    800060d8:	0027d783          	lhu	a5,2(a5)
    800060dc:	04f70863          	beq	a4,a5,8000612c <virtio_disk_intr+0x8a>
    __sync_synchronize();
    800060e0:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    800060e4:	6898                	ld	a4,16(s1)
    800060e6:	0204d783          	lhu	a5,32(s1)
    800060ea:	8b9d                	andi	a5,a5,7
    800060ec:	078e                	slli	a5,a5,0x3
    800060ee:	97ba                	add	a5,a5,a4
    800060f0:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    800060f2:	00278713          	addi	a4,a5,2
    800060f6:	0712                	slli	a4,a4,0x4
    800060f8:	9726                	add	a4,a4,s1
    800060fa:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    800060fe:	e721                	bnez	a4,80006146 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006100:	0789                	addi	a5,a5,2
    80006102:	0792                	slli	a5,a5,0x4
    80006104:	97a6                	add	a5,a5,s1
    80006106:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80006108:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000610c:	ffffc097          	auipc	ra,0xffffc
    80006110:	fa6080e7          	jalr	-90(ra) # 800020b2 <wakeup>

    disk.used_idx += 1;
    80006114:	0204d783          	lhu	a5,32(s1)
    80006118:	2785                	addiw	a5,a5,1
    8000611a:	17c2                	slli	a5,a5,0x30
    8000611c:	93c1                	srli	a5,a5,0x30
    8000611e:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006122:	6898                	ld	a4,16(s1)
    80006124:	00275703          	lhu	a4,2(a4)
    80006128:	faf71ce3          	bne	a4,a5,800060e0 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000612c:	0001c517          	auipc	a0,0x1c
    80006130:	bfc50513          	addi	a0,a0,-1028 # 80021d28 <disk+0x128>
    80006134:	ffffb097          	auipc	ra,0xffffb
    80006138:	b52080e7          	jalr	-1198(ra) # 80000c86 <release>
}
    8000613c:	60e2                	ld	ra,24(sp)
    8000613e:	6442                	ld	s0,16(sp)
    80006140:	64a2                	ld	s1,8(sp)
    80006142:	6105                	addi	sp,sp,32
    80006144:	8082                	ret
      panic("virtio_disk_intr status");
    80006146:	00002517          	auipc	a0,0x2
    8000614a:	6e250513          	addi	a0,a0,1762 # 80008828 <syscalls+0x3d8>
    8000614e:	ffffa097          	auipc	ra,0xffffa
    80006152:	3ee080e7          	jalr	1006(ra) # 8000053c <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
