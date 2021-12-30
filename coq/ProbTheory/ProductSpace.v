Require Import Program.Basics.
Require Import Coquelicot.Coquelicot.
Require Import Coq.Reals.Rbase.
Require Import Coq.Reals.Rfunctions.
Require Import Coq.Reals.RiemannInt.
Require Import Reals.

Require Import Lra Lia.
Require Import List Permutation.
Require Import Morphisms EquivDec.
Require Import Equivalence.
Require Import Classical ClassicalFacts ClassicalChoice.
Require Ensembles.

Require Import Utils DVector.
Import ListNotations.
Require Export Event SigmaAlgebras ProbSpace.
Require Export RandomVariable VectorRandomVariable.
Require Import ClassicalDescription.
Require Import Measures.
Require Import DiscreteProbSpace.

Set Bullet Behavior "Strict Subproofs".

Local Open Scope prob.

Section measure_product.

  Context {X Y:Type}.
  Context {A:SigmaAlgebra X}.
  Context {B:SigmaAlgebra Y}.

  Context (α : event A -> Rbar) (meas_α : is_measure α).
  Context (β : event B -> Rbar) (meas_β : is_measure β).
  
  Definition is_measurable_rectangle (ab : pre_event (X*Y)) : Prop
    := exists (a:event A) (b:event B), forall x y, ab (x,y) <-> a x /\ b y.

  Lemma is_measurable_rectangle_none : is_measurable_rectangle pre_event_none.
  Proof.
    exists event_none, event_none.
    unfold event_none, pre_event_none; simpl; tauto.
  Qed.
  
  Program Instance PairSemiAlgebra : SemiAlgebra (X*Y)
    := {|
      salg_in (x:pre_event (X*Y)) := is_measurable_rectangle x
    |}.
  Next Obligation.
    exists pre_Ω.
    exists Ω, Ω; intros; unfold Ω, pre_Ω; simpl.
    tauto.
  Qed.
  Next Obligation.
    destruct H as [a1[b1 ?]]; destruct H0 as [a2[b2 ?]].
    exists (event_inter a1 a2).
    exists (event_inter b1 b2).
    intros.
    split; intros [??].
    - apply H in H1.
      apply H0 in H2.
      repeat split; try apply H1; try apply H2.
    - destruct H1.
      destruct H2.
      split.
      + apply H.
        split; trivial.
      + apply H0.
        split; trivial.
  Qed.
  Next Obligation.
    destruct H as [a1[b1 ?]].
    exists ([(fun ab => event_complement a1 (fst ab) /\ b1 (snd ab))
        ; (fun ab => a1 (fst ab) /\ event_complement b1 (snd ab))
        ; (fun ab => event_complement a1 (fst ab) /\ event_complement b1 (snd ab))]).
    split;[ | split].
    - intros [x y].
      destruct a1; destruct b1; simpl.
      unfold pre_list_union, pre_event_complement.
      specialize (H x y).
      apply not_iff_compat in H.
      simpl in *; split.
      + intros ?.
        apply H in H0.
        apply not_and_or in H0.
        destruct H0.
        * destruct (classic (x1 y)).
          -- eexists; split; [left; reflexivity |].
             now simpl.
          -- eexists; split; [right; right; left; reflexivity |].
             now simpl.
        * destruct (classic (x0 x)).
          -- eexists; split; [right; left; reflexivity |].
             now simpl.
          -- eexists; split; [right; right; left; reflexivity |].
             now simpl.
      + intros [??].
        apply H.
        repeat destruct H0; simpl in *; tauto.
    - repeat constructor; intros ???
      ; destruct a1; destruct b1; simpl in *; firstorder.
    - repeat constructor.
      + exists (event_complement a1), b1; intros; tauto.
      + exists a1, (event_complement b1); intros; tauto.
      + exists (event_complement a1), (event_complement b1); intros; tauto.
  Qed.

  (* this is very classic *)
  Definition measurable_rectangle_pm (ab:salg_set PairSemiAlgebra) : Rbar.
  Proof.
    destruct ab as [? HH].
    simpl in HH.
    unfold is_measurable_rectangle in HH.
    apply IndefiniteDescription.constructive_indefinite_description in HH.
    destruct HH as [a HH].
    apply IndefiniteDescription.constructive_indefinite_description in HH.
    destruct HH as [b HH].
    exact (Rbar_mult (α a) (β b)).
  Defined.

  (* well, at least the definition is meaningful and proper *)
  Lemma measurable_rectangle_pm_proper' ab ab2
        (pf1:is_measurable_rectangle ab) (pf2:is_measurable_rectangle ab2) :
    pre_event_equiv ab ab2 ->
    measurable_rectangle_pm (exist _ ab pf1) = measurable_rectangle_pm (exist _ ab2 pf2).
  Proof.
    intros eqq.
    unfold measurable_rectangle_pm.
    repeat match_destr.
    destruct e as [??].
    destruct e0 as [??].
    destruct pf1 as [? [??]].
    destruct pf2 as [? [??]].

    destruct (classic_event_none_or_has x) as [[??]|?].
    - destruct (classic_event_none_or_has x0) as [[??]|?].
      + destruct (i x9 x10) as [_ ?].
        cut_to H5; [| tauto].
        apply eqq in H5.
        apply i0 in H5.
        destruct H5.
        f_equal.
        * apply measure_proper; intros c.
          split; intros HH.
          -- specialize (i c x10).
             destruct i as [_ ?].
             cut_to H7; [| tauto].
             apply eqq in H7.
             apply i0 in H7.
             tauto.
          -- specialize (i0 c x10).
             destruct i0 as [_ ?].
             cut_to H7; [| tauto].
             apply eqq in H7.
             apply i in H7.
             tauto.
        * apply measure_proper; intros c.
          split; intros HH.
          -- specialize (i x9 c).
             destruct i as [_ ?].
             cut_to H7; [| tauto].
             apply eqq in H7.
             apply i0 in H7.
             tauto.
          -- specialize (i0 x9 c).
             destruct i0 as [_ ?].
             cut_to H7; [| tauto].
             apply eqq in H7.
             apply i in H7.
             tauto.
      + rewrite H4.
        destruct (classic_event_none_or_has x2) as [[??]|?].
        * destruct (classic_event_none_or_has x1) as [[??]|?].
          -- specialize (i0 x11 x10).
             destruct i0 as [_ ?].
             cut_to H7; [| tauto].
             apply eqq in H7.
             apply i in H7.
             destruct H7 as [_ HH].
             apply H4 in HH.
             red in HH; tauto.
          -- rewrite H6.
             repeat rewrite measure_none.
             now rewrite Rbar_mult_0_l, Rbar_mult_0_r.
        * rewrite H5.
          repeat rewrite measure_none.
          now repeat rewrite Rbar_mult_0_r.
    - rewrite H3.
      destruct (classic_event_none_or_has x1) as [[??]|?].
      + destruct (classic_event_none_or_has x2) as [[??]|?].
        * destruct (i0 x9 x10) as [_ ?].
          cut_to H6; [| tauto].
          apply eqq in H6.
          apply i in H6.
          destruct H6 as [HH _].
          apply H3 in HH.
          red in HH; tauto.
        * rewrite H5.
          repeat rewrite measure_none.
          now rewrite Rbar_mult_0_l, Rbar_mult_0_r.
      + rewrite H4.
        repeat rewrite measure_none.
        now repeat rewrite Rbar_mult_0_l.
  Qed.
  
  Global Instance measurable_rectangle_pm_proper : Proper (salg_equiv ==> eq) measurable_rectangle_pm.
  Proof.
    intros ???.
    destruct x; destruct y.
    red in H; simpl in H.
    now apply measurable_rectangle_pm_proper'.
  Qed.

  Lemma measurable_rectangle_pm_nneg ab :
    Rbar_le 0 (measurable_rectangle_pm ab).
  Proof.
    unfold measurable_rectangle_pm.
    repeat match_destr.
    apply Rbar_mult_nneg_compat; apply measure_nneg.
  Qed.

  Lemma measurable_rectangle_pm_none :
    measurable_rectangle_pm (exist _ _ is_measurable_rectangle_none) = 0.
  Proof.
    unfold measurable_rectangle_pm.
    repeat match_destr.
    destruct (classic_event_none_or_has x) as [[??]|?].
    - destruct (classic_event_none_or_has x0) as [[??]|?].
      + destruct (i x1 x2) as [_ HH].
        cut_to HH; [| tauto].
        now red in HH.
      + rewrite H0.
        now rewrite measure_none, Rbar_mult_0_r.
    - rewrite H.
      now rewrite measure_none, Rbar_mult_0_l.
  Qed.

  (* this lemma could be used to clean up some of the above *)
  Lemma measurable_rectangle_eq_decompose
        (fx:event A) (fy:event B) (gx:event A) (gy:event B) :
    (forall (x : X) (y : Y), fx x /\ fy y <-> gx x /\ gy y) ->
    ((event_equiv fx ∅ \/ event_equiv fy ∅) /\ (event_equiv gx ∅ \/ event_equiv gy ∅))
    \/ (event_equiv fx gx /\ event_equiv fy gy).
  Proof.
    intros.
    destruct (classic_event_none_or_has fx) as [[??]|?].
    - destruct (classic_event_none_or_has fy) as [[??]|?].
      + right.
        split; intros c; split; intros HH.
        * destruct (H c x0) as [[??] _]; tauto.
        * destruct (H c x0) as [_ [??]]; trivial.
          split; trivial.
          destruct (H x x0) as [[??] _]; tauto.
        * destruct (H x c) as [[??] _]; tauto.
        * destruct (H x c) as [_ [??]]; trivial.
          split; trivial.
          destruct (H x x0) as [[??] _]; tauto.
      + destruct (classic_event_none_or_has gx) as [[??]|?]; [| eauto].
        destruct (classic_event_none_or_has gy) as [[??]|?]; [| eauto].
        destruct (H x0 x1) as [_ [??]]; [tauto |].
        apply H1 in H5; tauto.
    - left.
      destruct (classic_event_none_or_has gx) as [[??]|?]; [| eauto].
      destruct (classic_event_none_or_has gy) as [[??]|?]; [| eauto].
      destruct (H x x0) as [_ [??]]; [tauto |].
      apply H0 in H3; tauto.
  Qed.      

  Definition product_measure := semi_μ measurable_rectangle_pm.

  (* This hypothesis is true, however all the proofs that I have found use 
     the MCT (monotone convergence theorom) over the measure integral, which we have not defined
     in general.
     However, our immediate goal is to define the product of probability spaces,
     where we have defined it (Expectation), and proven the MCT.
     So for now, we leave it as an obligation, which we will discharge in the context we care about
   *)
  Definition measure_rectangle_pm_additive_Hyp :=
             forall B0 : nat -> salg_set PairSemiAlgebra,
  pre_collection_is_pairwise_disjoint (fun x : nat => B0 x) ->
  forall pf : salg_in (pre_union_of_collection (fun x : nat => B0 x)),
  measurable_rectangle_pm (exist salg_in (pre_union_of_collection (fun x : nat => B0 x)) pf) =
    ELim_seq (fun i : nat => sum_Rbar_n (fun n : nat => measurable_rectangle_pm (B0 n)) i).

  Context (Hyp : measure_rectangle_pm_additive_Hyp).
          
  Instance measurable_rectangle_pm_semipremeasure : is_semipremeasure measurable_rectangle_pm.
  Proof.
    apply (semipremeasure_with_zero_simpl) with (has_none:=is_measurable_rectangle_none).
    - apply measurable_rectangle_pm_proper.
    - apply measurable_rectangle_pm_nneg.
    - apply measurable_rectangle_pm_none.
    - exact Hyp.
  Qed.

  Instance product_measure_is_measurable_large :
    is_measure (σ:= semi_σ is_measurable_rectangle_none
                           measurable_rectangle_pm
                           measurable_rectangle_pm_none
               ) product_measure
    := semi_μ_measurable _ _ _.

  (* we can cut down to the (possibly smaller)
     generated sigma algebra *)
  Global Instance product_measure_is_measurable :
    is_measure (σ:=product_sa A B) product_measure.
  Proof.
    generalize product_measure_is_measurable_large; intros HH.
    assert (sub:sa_sub (product_sa A B)
                       (semi_σ is_measurable_rectangle_none
                               measurable_rectangle_pm
                               measurable_rectangle_pm_none
           )).
    {
      unfold product_sa; intros ?.
      apply generated_sa_minimal; simpl; intros.
      apply semi_σ_in.
      simpl.
      destruct H as [?[?[?[??]]]].
      red.
      exists (exist _ _ H).
      exists (exist _ _ H0); intros.
      apply H1.
    } 
    apply (is_measure_proper_sub _ _ sub) in HH.
    now simpl in HH.
  Qed.

  Theorem product_measure_product (a:event A) (b:event B) :
    product_measure (fun '(x,y) => a x /\ b y) = Rbar_mult (α a) (β b).
  Proof.
    unfold product_measure.
    generalize (semi_μ_λ is_measurable_rectangle_none _ measurable_rectangle_pm_none)
    ; intros HH.
    assert (pin:salg_in (fun '(x1, y) => a x1 /\ b y)).
    {
      simpl.
      exists a; exists b; tauto.
    }
    specialize (HH (exist _ _ pin)).
    simpl in *.
    rewrite HH.
    repeat match_destr.
    apply measurable_rectangle_eq_decompose in i.
    destruct i as [[[?|?][?|?]]|[??]]
    ; try solve [
          rewrite H, H0
          ; repeat rewrite measure_none
          ; repeat rewrite Rbar_mult_0_r
          ; repeat rewrite Rbar_mult_0_l; trivial].      
  Qed.
  
End measure_product.

Require Import RandomVariableFinite.
Section ps_product.
  Context {X Y:Type}.
  Context {A:SigmaAlgebra X}.
  Context {B:SigmaAlgebra Y}.

  Context (ps1 : ProbSpace A).
  Context (ps2 : ProbSpace B).

  Lemma sum_Rbar_n_finite_sum_n f n:
    sum_Rbar_n (fun x => Finite (f x)) (S n) = Finite (sum_n f n).
  Proof.
    rewrite sum_n_fold_right_seq.
    unfold sum_Rbar_n, list_Rbar_sum.
    generalize (0).
    induction n; trivial; intros.
    rewrite seq_Sn.
    repeat rewrite map_app.
    repeat rewrite fold_right_app.
    now rewrite <- IHn.
  Qed.

  Lemma Lim_seq_sum_Elim f :
    Lim_seq (sum_n f) = ELim_seq (sum_Rbar_n (fun x => Finite (f x))).
  Proof.
    rewrite <- ELim_seq_incr_1.
    rewrite <- Elim_seq_fin.
    apply ELim_seq_ext; intros.
    now rewrite sum_Rbar_n_finite_sum_n.
  Qed.    

  Lemma rbar_nneg_nneg x :
    Rbar_le 0 x ->
    0 <= x.
  Proof.
    destruct x; simpl; try lra.
  Qed.

  Lemma rvlim_isfe {S} {σ:SigmaAlgebra S} (ps:ProbSpace σ) (f:nat->S->R) : (forall omega, NonnegativeFunction (f omega)) -> (forall omega, ex_finite_lim_seq (fun n => f n omega)) -> IsFiniteExpectation ps (rvlim f).
  Proof.
    intros.
  Admitted.


  Lemma product_measure_Hyp_ps :
    measure_rectangle_pm_additive_Hyp (ps_P (σ:=A)) (ps_measure _) (ps_P (σ:=B)) (ps_measure _).
  Proof.
    red.
    intros c cdisj pf.

    assert (HH:forall s, exists (ab:(event A * event B)), forall x y, (c s) (x,y) <-> fst ab x /\ snd ab y).
    {
      intros.
      destruct (c s); simpl.
      destruct s0 as [?[??]].
      exists (x0,x1); auto.
    }
    apply choice in HH.
    destruct HH as [cp HH].
    pose (α := (ps_P (σ:=A))).
    pose (β := (ps_P (σ:=B))).
    transitivity (ELim_seq (sum_Rbar_n
                              (fun n : nat =>
                                 (Rbar_mult (α (fst (cp n))) (β (snd (cp n))))))).
    - unfold measurable_rectangle_pm.
      repeat match_destr.
      clear e.
      rename x into a.
      rename x0 into b.
      assert (forall x y, (exists n, (fst (cp n) x) /\ snd (cp n) y) <-> a x /\ b y).
      {
        unfold pre_union_of_collection in i.
        intros.
        rewrite <- (i x y).
        split; intros [??]
        ; apply HH in H; eauto.
      }

      unfold α, β in *.
      simpl.
      rewrite <- Lim_seq_sum_Elim.
      Existing Instance IsFiniteExpectation_simple.
      
      assert (eqq1:forall (a:event A) (b:event B),
                 (ps_P a) * (ps_P b) =
                   (FiniteExpectation ps1 (EventIndicator (classic_dec a))) * (FiniteExpectation ps2 (EventIndicator (classic_dec b)))).
      {
        intros.
        now repeat rewrite FiniteExpectation_indicator.
      }
      
      assert (eqq2:forall (a:event A) (b:event B),
                 (ps_P a) * (ps_P b) =
                   FiniteExpectation ps2
                                     (rvscale (FiniteExpectation ps1 (EventIndicator (classic_dec a)))
                                              (EventIndicator (classic_dec b))
             )).
      {
        intros; rewrite eqq1.
        now rewrite FiniteExpectation_scale.
      }

      assert (eqq3': forall (a:event A) (b:event B),
                 rv_eq (rvscale (FiniteExpectation ps1 (EventIndicator (classic_dec a))) (EventIndicator (classic_dec b)))
                       (fun y : Y =>
                          FiniteExpectation ps1 (fun x : X => EventIndicator (classic_dec b) y * EventIndicator (classic_dec a) x))).
      {
        intros ???.
        unfold rvscale.
        rewrite Rmult_comm.
        now rewrite <- FiniteExpectation_scale.
      }
      
      assert (isfe3:forall (a:event A) (b:event B),
                   IsFiniteExpectation ps2
                                     (fun y => FiniteExpectation ps1 (fun x => (EventIndicator (classic_dec b) y) * (EventIndicator (classic_dec a) x)))).
      {
        intros.
        eapply IsFiniteExpectation_proper; try (symmetry; eapply eqq3').
        typeclasses eauto.
      } 

      assert (eqq3:forall (a:event A) (b:event B),
                 (ps_P a) * (ps_P b) =
                   FiniteExpectation ps2
                                     (fun y => FiniteExpectation ps1 (fun x => (EventIndicator (classic_dec b) y) * (EventIndicator (classic_dec a) x)))).
                            
      {
        intros; rewrite eqq2.
        apply FiniteExpectation_ext.
        apply eqq3'.
      } 

      clear eqq1 eqq2 eqq3'.

      rewrite eqq3.
      symmetry.
      etransitivity.
      {
        apply Lim_seq_ext; intros ?.
        apply sum_n_ext; intros.
        rewrite eqq3.
        reflexivity.
      }

      {
        assert (rvf: forall n, RandomVariable B borel_sa
                                    (fun y : Y =>
                                       FiniteExpectation ps1
                       (fun x : X =>
                          EventIndicator (classic_dec (snd (cp n))) y * EventIndicator (classic_dec (fst (cp n))) x))).
        {
          intros n.
          setoid_rewrite FiniteExpectation_scale.
          setoid_rewrite rvmult_comm.
          unfold rvmult.
          apply rvscale_rv.
          typeclasses eauto.
        }
        assert (exf:forall omega : Y,
                   ex_finite_lim_seq
                     (fun n : nat =>
                        sum_n
                          (fun n0 : nat =>
                             FiniteExpectation ps1
                                               (fun x : X =>
                                                  EventIndicator (classic_dec (snd (cp n0))) omega * EventIndicator (classic_dec (fst (cp n0))) x))
                          n)).
        {
          intros.
          intros.
          apply ex_finite_lim_seq_correct.
          split.
          - apply ex_lim_seq_incr.
            intros.
            apply sum_n_pos_incr; intros; try lia.
            apply FiniteExpectation_pos.
            typeclasses eauto.
          - rewrite (Lim_seq_ext _
                                 (sum_n (fun n0 =>
                                           EventIndicator (classic_dec (snd (cp n0))) omega *
                                             FiniteExpectation ps1 (EventIndicator (classic_dec (fst (cp n0))))))).
            2: {
              intros.
              apply sum_n_ext; intros.
              setoid_rewrite FiniteExpectation_scale.
              reflexivity.
            }
            rewrite (Lim_seq_ext _
                                 (sum_n
                                    (fun n0 : nat =>
                                       EventIndicator (classic_dec (snd (cp n0))) omega * ps_P(fst (cp n0))))).
            2: {
              intros.
              apply sum_n_ext; intros.
              now rewrite FiniteExpectation_indicator.
            }
            unfold EventIndicator.
            admit.
        } 
        erewrite series_expectation.
        Unshelve.
        shelve.
        - intros ??.
          apply FiniteExpectation_pos.
          typeclasses eauto.
        - trivial. 
        - apply rvlim_rv; trivial.
          intros.
          apply rvsum_rv; intros; trivial.
        - intros.
          specialize (exf omega).
          apply ex_finite_lim_seq_correct in exf.
          apply exf.
        - intros ?.
          apply rbar_nneg_nneg.
          apply Lim_seq_pos; intros.
          apply rvsum_pos; intros ??.
          apply FiniteExpectation_pos.
          typeclasses eauto.
        - intros; specialize (exf omega).
          apply ex_finite_lim_seq_correct in exf.
          apply exf.
        - apply rvlim_isfe; intros; try apply exf.
          apply rvsum_pos; intros ??.
          apply FiniteExpectation_pos.
          typeclasses eauto.
      }
      Unshelve.
      f_equal.
      apply FiniteExpectation_ext; intros y.
      {
        unfold rvsum.
        assert (exf2:forall omega, ex_finite_lim_seq
                       (fun n : nat =>
                          sum_n
                            (fun n0 : nat =>
                               EventIndicator (classic_dec (snd (cp n0))) y * EventIndicator (classic_dec (fst (cp n0))) omega) n)).
        {
          intros.
          apply ex_finite_lim_seq_correct.
          split.
          - apply ex_lim_seq_incr.
            intros.
            apply sum_n_pos_incr; try lia; intros.
            unfold EventIndicator.
            repeat match_destr; lra.
          - unfold EventIndicator.
            (* in fact, there is at most one that it holds for *)
            admit.
        } 

        erewrite series_expectation
        ; try typeclasses eauto.
        Unshelve.
        shelve.
        - apply rvlim_rv; intros.
          apply rvsum_rv; intros.
          + typeclasses eauto.
          + apply exf2.
        - intros; specialize (exf2 omega).
          apply ex_finite_lim_seq_correct in exf2.
          apply exf2.
        - intros; specialize (exf2 omega).
          apply ex_finite_lim_seq_correct in exf2.
          apply exf2.
        - apply rvlim_isfe; trivial.
          typeclasses eauto.
      }
      Unshelve.
      f_equal.
      apply FiniteExpectation_ext; intros x.
      unfold EventIndicator, rvsum.
      (* now we finally have it down to points *)
      {
        admit.
      }
    - apply ELim_seq_ext; intros.
      unfold sum_Rbar_n.
      f_equal.
      apply map_ext; intros.
      unfold measurable_rectangle_pm.
      clear n.
      specialize (HH a).
      repeat match_destr.
      simpl in HH.
      assert (eqq:forall a1 b1, fst (cp a) a1 /\ snd (cp a) b1 <-> x0 a1 /\ x1 b1).
      {
        intros.
        etransitivity.
        - symmetry; apply HH.
        - apply i.
      }
      clear HH i e.
      apply measurable_rectangle_eq_decompose in eqq.
      unfold α, β in *.
      destruct eqq as [[[?|?][?|?]]|[??]]
      ; try solve [
            rewrite H, H0
            ; repeat rewrite ps_none
            ; repeat rewrite Rbar_mult_0_r
            ; repeat rewrite Rbar_mult_0_l; trivial].      
  Admitted.
  
  (* We discharge the extra hypothesis here *)
  Instance product_measure_is_measurable_ps :
    is_measure (σ:=product_sa A B)
               (product_measure (ps_P (σ:=A)) (ps_measure _) (ps_P (σ:=B)) (ps_measure _)).
  Proof.
    apply product_measure_is_measurable.
    apply product_measure_Hyp_ps.
  Qed.

  Instance product_ps : ProbSpace (product_sa A B).
  Proof.
    apply (measure_all_one_ps (product_measure (ps_P (σ:=A)) (ps_measure _) (ps_P (σ:=B)) (ps_measure _))).
    generalize (product_measure_product (ps_P (σ:=A)) (ps_measure _) (ps_P (σ:=B)) (ps_measure _) product_measure_Hyp_ps Ω Ω)
    ; intros HH.
    repeat rewrite ps_one in HH.
    rewrite Rbar_mult_1_r in HH.
    rewrite <- HH.
    assert (pre_eqq:pre_event_equiv
              pre_Ω
              (fun '(x,y) => @pre_Ω X x /\ @pre_Ω Y y)).
    {
      intros [??]; tauto.
    }
    assert (sa:sa_sigma (SigmaAlgebra:=product_sa A B) (fun '(x,y) => @pre_Ω X x /\ @pre_Ω Y y)).
    { 
      rewrite <- pre_eqq.
      apply sa_all.
    }
    apply (measure_proper (σ:=product_sa A B) (μ:=product_measure (fun x : event A => ps_P x) (ps_measure ps1) (fun x : event B => ps_P x) 
                                                                  (ps_measure ps2)) Ω (exist _ _ sa)).
    now red; simpl.
  Defined.

  Lemma product_sa_sa (a:event A) (b:event B) :
    sa_sigma (SigmaAlgebra:=product_sa A B) (fun '(x,y) => a x /\ b y).
  Proof.
    apply generated_sa_sub.
    red.
    destruct a; destruct b; simpl.
    exists x; exists x0.
    firstorder.
  Qed.

  Definition product_sa_event (a:event A) (b:event B) : event (product_sa A B)
    := exist _ _ (product_sa_sa a b).
  
  Theorem product_sa_product (a:event A) (b:event B) :
    ps_P (ProbSpace:=product_ps) (product_sa_event a b) =
      ps_P a * ps_P b.
  Proof.
    simpl.
    rewrite product_measure_product; simpl; trivial.
    apply product_measure_Hyp_ps.
  Qed.
  
End ps_product.
