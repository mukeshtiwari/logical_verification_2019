/- LoVe Demo 1: Definitions and Lemma Statements -/

import .lovelib

namespace LoVe


/- Types and Terms -/
#eval 1 + 1
#check ℕ
#check ℤ

#check empty
#check unit
#check bool

#check ℕ → ℤ
#check ℤ → ℕ
#check bool → ℕ → ℤ
#check (bool → ℕ) → ℤ
#check ℕ → (bool → ℕ) → ℤ

#check λx : ℕ, x
#check λf : ℕ → ℕ, λg : ℕ → ℕ, λh : ℕ → ℕ, λx : ℕ, h (g (f x))
#check λ(f g h : ℕ → ℕ) (x : ℕ), h (g (f x))

constants a b : ℤ
constant f : ℤ → ℤ
constant g : ℤ → ℤ → ℤ

#check λx : ℤ, g (f (g a x)) (g x b)
#check λx, g (f (g a x)) (g x b)

#check λx, x

constant trool : Type
constants ttrue tfalse tmaybe : trool


/- Type Definitions -/

namespace my_nat

inductive nat : Type
| zero : nat
| succ : nat → nat

#check nat
#check nat.zero
#check nat.succ

end my_nat

#print nat
#print ℕ

namespace my_list

inductive list (α : Type) : Type
| nil : list
| cons : α → list → list

#check list.nil
#check list.cons

end my_list

#print list

inductive aexp : Type
| num : ℤ → aexp
| var : string → aexp
| add : aexp → aexp → aexp
| sub : aexp → aexp → aexp
| mul : aexp → aexp → aexp
| div : aexp → aexp → aexp


/- Function Definitions -/

def add : ℕ → ℕ → ℕ
| m nat.zero     := m
| m (nat.succ n) := nat.succ (add m n)

#reduce add 2 7
#eval add 2 7

def mul : ℕ → ℕ → ℕ
| _ nat.zero     := nat.zero
| m (nat.succ n) := add m (mul m n)

#reduce mul 2 7

#print mul
#print mul._main

def power : ℕ → ℕ → ℕ
| _ 0            := 1
| m (nat.succ n) := m * power m n

#reduce power 2 5

def power₂ (m : ℕ) : ℕ → ℕ
| 0            := 1
| (nat.succ n) := m * power₂ n

#reduce power₂ 2 5

def iter (α : Type) (z : α) (f : α → α) : ℕ → α
| 0            := z
| (nat.succ n) := f (iter n)

#check iter

def power₃ (m n : ℕ) : ℕ :=
iter ℕ 1 (λl, m * l) n

#reduce power₃ 2 5

/-
-- illegal
def evil : ℕ → ℕ
| n := nat.succ (evil n)
-/

def append (α : Type) : list α → list α → list α
| list.nil         ys := ys
| (list.cons x xs) ys := list.cons x (append xs ys)

#check append
#reduce append _ [3, 1] [4, 1, 5]

def append₂ {α : Type} : list α → list α → list α
| list.nil         ys := ys
| (list.cons x xs) ys := list.cons x (append₂ xs ys)

#check append₂
#reduce append₂ [3, 1] [4, 1, 5]

#check @append₂
#reduce @append₂ _ [3, 1] [4, 1, 5]

def append₃ {α : Type} : list α → list α → list α
| []        ys := ys
| (x :: xs) ys := x :: append₃ xs ys

def reverse {α : Type} : list α → list α
| []        := []
| (x :: xs) := reverse xs ++ [x]

def eval (env : string → ℤ) : aexp → ℤ
| (aexp.num i)     := i
| (aexp.var x)     := env x
| (aexp.add e₁ e₂) := eval e₁ + eval e₂
| (aexp.sub e₁ e₂) := eval e₁ - eval e₂
| (aexp.mul e₁ e₂) := eval e₁ * eval e₂
| (aexp.div e₁ e₂) := eval e₁ / eval e₂


/- Lemma Statements -/

namespace sorry_lemmas

lemma add_zero : forall (n : ℕ), 
  add 0 n = n 
 | nat.zero := refl 0
 | (nat.succ n') := 
   begin 
     simp[add], apply add_zero 
   end

lemma add_succ_zero : forall (n : ℕ),
  add (nat.succ n) nat.zero = nat.succ (add n nat.zero)
  | nat.zero := refl 1
  | (nat.succ n') := by simp[add]   

set_option trace.eqn_compiler.elim_match true

lemma add_succ_n : forall (n m : ℕ), 
  add (nat.succ n) m = nat.succ (add n m) 
| nat.zero nat.zero := refl 1
| nat.zero (nat.succ m') := begin 
   simp[add], rw add_zero, 
   rw [add_succ_n 0 m', add_zero] end
| (nat.succ n') nat.zero := by simp[add]
| (nat.succ n') (nat.succ m') := begin 
    simp[add], rw [add_succ_n (nat.succ n') m']
 end 

lemma add_comm : forall (m : ℕ) (n : ℕ), 
  add m n = add n m 
 | nat.zero nat.zero := refl nat.zero 
 | nat.zero (nat.succ n') := begin 
   simp[add], rw add_zero end
 | (nat.succ m') nat.zero := begin
     simp[add], apply (add_comm m' 0)
   end 
 | (nat.succ m') (nat.succ n') := begin 
    simp[add], rw [add_succ_n], rw add_succ_n,
    rw add_comm
 end 


lemma add_assoc : forall (l m n : ℕ),
  add (add l m) n = add l (add m n) 

| nat.zero m n := by repeat {rw add_zero}  
|(nat.succ l') m n := begin  
  repeat {rw add_succ_n}, rw (add_assoc l' m n),
end
   
lemma mul_zero : forall n, mul 0 n = 0
| nat.zero := refl 0
| (nat.succ n') := begin simp [mul], 
   rw [add_zero, mul_zero] end

lemma mul_one : forall n, mul 1 n = n
| nat.zero := refl 0 
| (nat.succ n') := begin 
    simp[mul], rw mul_one,  rw add_succ_n,
    rw add_zero
end

lemma mul_succ : forall m n, mul (nat.succ m) n = add n (mul n m)
| nat.zero n := begin simp[mul, add], rw mul_one end
|(nat.succ m') n := begin
    repeat {simp [mul]},     
 end

lemma mul_comm : forall (m n : ℕ), 
  mul m n = mul n m 
| nat.zero n := begin  simp [mul], rw mul_zero end
| (nat.succ m') n := begin 
  simp [mul], rw mul_succ
end 

lemma mul_assoc (l m n : ℕ) :
  mul (mul l m) n = mul l (mul m n) :=
sorry

lemma mul_add (l m n : ℕ) :
  mul l (add m n) = add (mul l m) (mul l n) :=
sorry

lemma reverse_reverse {α : Type} (xs : list α) :
  reverse (reverse xs) = xs :=
sorry

end sorry_lemmas

end LoVe
