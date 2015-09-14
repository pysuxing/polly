; RUN: opt %loadPolly -polly-scops -polly-detect-unprofitable -analyze < %s | FileCheck %s
;
; CHECK: Domain :=
; CHECK:   [N, P, Q] -> { Stmt_if_end[i0] : (i0 >= 0 and i0 <= 1 + Q and i0 <= -1 + P and i0 <= -1 + N) or (P <= -1 and i0 >= 1 + P - Q and i0 >= 0 and i0 <= 1 + Q and i0 <= -1 + N); Stmt_if_end[0] : (N >= 1 and P <= -2 and Q <= -2) or (N >= 1 and P >= 1 and Q <= -2) or (P = -1 and N >= 1) }
;
;    void f(int *A, int N, int P, int Q) {
;      for (int i = 0; i < N; i++) {
;        if (i == P)
;          break;
;        A[i]++;
;        if (i > Q)
;          break;
;      }
;    }
;
target datalayout = "e-m:e-i64:64-f80:128-n8:16:32:64-S128"

define void @f(i32* %A, i32 %N, i32 %P, i32 %Q) {
entry:
  %tmp = sext i32 %N to i64
  %tmp1 = sext i32 %Q to i64
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %indvars.iv = phi i64 [ %indvars.iv.next, %for.inc ], [ 0, %entry ]
  %cmp = icmp slt i64 %indvars.iv, %tmp
  br i1 %cmp, label %for.body, label %for.end.loopexit

for.body:                                         ; preds = %for.cond
  %tmp2 = trunc i64 %indvars.iv to i32
  %cmp1 = icmp eq i32 %tmp2, %P
  br i1 %cmp1, label %if.then, label %if.end

if.then:                                          ; preds = %for.body
  br label %for.end

if.end:                                           ; preds = %for.body
  %arrayidx = getelementptr inbounds i32, i32* %A, i64 %indvars.iv
  %tmp3 = load i32, i32* %arrayidx, align 4
  %inc = add nsw i32 %tmp3, 1
  store i32 %inc, i32* %arrayidx, align 4
  %cmp2 = icmp sgt i64 %indvars.iv, %tmp1
  br i1 %cmp2, label %if.then.3, label %if.end.4

if.then.3:                                        ; preds = %if.end
  br label %for.end

if.end.4:                                         ; preds = %if.end
  br label %for.inc

for.inc:                                          ; preds = %if.end.4
  %indvars.iv.next = add nuw nsw i64 %indvars.iv, 1
  br label %for.cond

for.end.loopexit:                                 ; preds = %for.cond
  br label %for.end

for.end:                                          ; preds = %for.end.loopexit, %if.then.3, %if.then
  ret void
}
