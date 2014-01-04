(*  Title:      SubgroupConjugation.thy
    Author:     Jakob von Raumer, Karlsruhe Institute of Technology
*)

theory SubgroupConjugation
imports
  "~~/src/HOL/Algebra/Ideal"
  "~~/src/HOL/Algebra/Group"
  "~~/src/HOL/Algebra/IntRing"
  "~~/src/HOL/Algebra/Bij"
  "~~/src/HOL/Algebra/Sylow"
  "~~/src/HOL/Algebra/Coset"
  "~~/src/HOL/Hilbert_Choice"
  "GroupAction"
begin

lemma (in subgroup) subgroup_of_subset:
  assumes G:"group G"
  assumes PH:"H \<subseteq> K"
  assumes KG:"subgroup K G"
  shows "subgroup H (G\<lparr>carrier := K\<rparr>)"
using assms subgroup_def group.subgroup_inv_equality m_inv_closed by fastforce

lemma (in group) lcosI:
     "[| h \<in> H; H \<subseteq> carrier G; x \<in> carrier G|] ==> x \<otimes> h \<in> x <# H"
by (auto simp add: l_coset_def)

lemma (in group) lcoset_join2:
     "\<lbrakk>x \<in> carrier G;  subgroup H G;  x\<in>H\<rbrakk> \<Longrightarrow> x <# H = H"
sorry

lemma (in group) conjugation_subgroup:
  assumes HG:"subgroup H G"
  assumes gG:"g \<in> carrier G"
  shows "subgroup (g <# (H #> inv g)) G"
proof
  from gG have "inv g \<in> carrier G" by (rule inv_closed)
  with HG have "(H #> inv g) \<subseteq> carrier G" by (metis r_coset_subset_G subgroup_imp_subset)
  with gG show "g <# (H #> inv g) \<subseteq> carrier G" by (metis l_coset_subset_G)
next
  from gG have invgG:"inv g \<in> carrier G" by (metis inv_closed)
  with HG have lcosSubset:"(H #> inv g) \<subseteq> carrier G" by (metis r_coset_subset_G subgroup_imp_subset)
  fix x y
  assume x:"x \<in> g <# (H #> inv g)" and y:"y \<in> g <# (H #> inv g)"
  then obtain x' y' where x':"x' \<in> H #> inv g" "x = g \<otimes> x'" and y':"y' \<in> H #> inv g" "y = g \<otimes> y'" unfolding l_coset_def by auto
  then obtain hx hy where hx:"hx \<in> H" "x' = hx \<otimes> inv g" and hy:"hy \<in> H" "y' = hy \<otimes> inv g" unfolding r_coset_def by auto
  with x' y' have x2:"x = g \<otimes> (hx \<otimes> inv g)" and y2:"y = g \<otimes> (hy \<otimes> inv g)" by auto
  hence "x \<otimes> y = (g \<otimes> (hx \<otimes> inv g)) \<otimes> (g \<otimes> (hy \<otimes> inv g))" by simp
  also from hx hy HG have hxG:"hx \<in> carrier G" and hyG:"hy \<in> carrier G" by (metis subgroup.mem_carrier)+
  with gG hy x2 invgG have "(g \<otimes> (hx \<otimes> inv g)) \<otimes> (g \<otimes> (hy \<otimes> inv g)) = g \<otimes> hx \<otimes> (inv g \<otimes> g) \<otimes> hy \<otimes> inv g" by (metis m_assoc m_closed)
  also from invgG gG have "... = g \<otimes> hx \<otimes> \<one> \<otimes> hy \<otimes> inv g" by simp
  also from gG hxG have "... = g \<otimes> hx \<otimes> hy \<otimes> inv g" by (metis m_closed r_one)
  also from gG hxG invgG have "... = g \<otimes> ((hx \<otimes> hy) \<otimes> inv g)" by (metis gG hxG hyG invgG m_assoc m_closed)
  finally have xy:"x \<otimes> y = g \<otimes> (hx \<otimes> hy \<otimes> inv g)".
  from hx hy HG have "hx \<otimes> hy \<in> H" by (metis subgroup.m_closed)
  with invgG HG have "(hx \<otimes> hy) \<otimes> inv g \<in> H #> inv g" by (metis rcosI subgroup_imp_subset)
  with gG lcosSubset have "g \<otimes> (hx \<otimes> hy \<otimes> inv g) \<in> g <# (H #> inv g)" by (metis lcosI)
  with xy show "x \<otimes> y \<in> g <# (H #> inv g)" by simp
next
  from gG have invgG:"inv g \<in> carrier G" by (metis inv_closed)
  with HG have lcosSubset:"(H #> inv g) \<subseteq> carrier G" by (metis r_coset_subset_G subgroup_imp_subset)
  from HG have "\<one> \<in> H" by (rule subgroup.one_closed)
  with invgG HG have  "\<one> \<otimes> inv g \<in> H #> inv g" by (metis rcosI subgroup_imp_subset)
  with gG lcosSubset have "g \<otimes> (\<one> \<otimes> inv g) \<in> g <# (H #> inv g)" by (metis lcosI)
  with gG invgG show "\<one> \<in> g <# (H #> inv g)" by simp
next
  from gG have invgG:"inv g \<in> carrier G" by (metis inv_closed)
  with HG have lcosSubset:"(H #> inv g) \<subseteq> carrier G" by (metis r_coset_subset_G subgroup_imp_subset)
  fix x
  assume "x \<in> g <# (H #> inv g)"
  then obtain x' where x':"x' \<in> H #> inv g" "x = g \<otimes> x'" unfolding l_coset_def by auto
  then obtain hx where hx:"hx \<in> H" "x' = hx \<otimes> inv g"  unfolding r_coset_def by auto
  with HG have invhx:"inv hx \<in> H" by (metis subgroup.m_inv_closed)
  from x' hx have "inv x = inv (g \<otimes> (hx \<otimes> inv g))" by simp
  also from x' hx HG gG invgG have "... = inv (inv g) \<otimes> inv hx \<otimes> inv g" by (metis calculation in_mono inv_mult_group lcosSubset subgroup.mem_carrier)
  also from gG have "... = g \<otimes> inv hx \<otimes> inv g" by simp
  also from gG invgG invhx HG have "... = g \<otimes> (inv hx \<otimes> inv g)" by (metis m_assoc subgroup.mem_carrier)
  finally have invx:"inv x = g \<otimes> (inv hx \<otimes> inv g)".
  with invhx invgG HG have "(inv hx) \<otimes> inv g \<in> H #> inv g" by (metis rcosI subgroup_imp_subset)
  with gG lcosSubset have "g \<otimes> (inv hx \<otimes> inv g) \<in> g <# (H #> inv g)" by (metis lcosI)
  with invx show "inv x \<in> g <# (H #> inv g)" by simp
qed

definition (in group) subgroups_of_size ::"nat \<Rightarrow> _"
  where "subgroups_of_size p = {H. subgroup H G \<and> card H = p}"

lemma (in group) rcos_m_assoc:
     "[| M \<subseteq> carrier G; g \<in> carrier G; h \<in> carrier G |]
      ==> (M #> g) #> h = M #> (g \<otimes> h)"
by (force simp add: r_coset_def m_assoc)

lemma (in group) rcos_mult_one: "M \<subseteq> carrier G ==> M #> \<one> = M"
by (force simp add: r_coset_def)

lemma (in group) cardeq_rcoset:
  assumes "finite (carrier G)"
  assumes "M \<subseteq> carrier G"
  assumes "g \<in> carrier G"
  shows "card (M #> g) = card  M"
proof -
  have "M #> g \<in> rcosets M" by (metis assms(2) assms(3) rcosetsI)
  thus "card (M #> g) = card M" by (metis assms(1) assms(2) card_cosets_equal)
qed


lemma (in group) cardeq_lcoset:
  assumes "finite (carrier G)"
  assumes M:"M \<subseteq> carrier G"
  assumes g:"g \<in> carrier G"
  shows "card (g <# M) = card  M"
proof -
  have "bij_betw (\<lambda>m. g \<otimes> m) M (g <# M)"
  proof(auto simp add: bij_betw_def)
    show "inj_on (op \<otimes> g) M"
    proof(rule inj_onI)
        from g have invg:"inv g \<in> carrier G" by (rule inv_closed)
        fix x y
        assume x:"x \<in> M" and y:"y \<in> M"
        with M have xG:"x \<in> carrier G" and yG:"y \<in> carrier G" by auto 
        assume "g \<otimes> x = g \<otimes> y"
        hence "(inv g) \<otimes> (g \<otimes> x) = (inv g) \<otimes> (g \<otimes> y)" by simp
        with g invg xG yG have "(inv g \<otimes> g) \<otimes> x = (inv g \<otimes> g) \<otimes> y" by (metis m_assoc)
        with g invg xG yG show  "x = y" by simp
    qed
  next
    fix x
    assume "x \<in> M"
    thus "g \<otimes> x \<in> g <# M" unfolding l_coset_def by auto
  next
    fix x
    assume x:"x \<in> g <# M"
    then obtain m where "x = g \<otimes> m" "m \<in> M" unfolding l_coset_def by auto
    thus "x \<in> op \<otimes> g ` M" by simp
  qed
  thus "card (g <# M) = card M" by (metis bij_betw_same_card)
qed

definition (in group) conjugation_action::"nat \<Rightarrow> _"
  where "conjugation_action p = (\<lambda>g\<in>carrier G. \<lambda>P\<in>subgroups_of_size p. g <# (P #> inv g))"

lemma (in group) conjugation_is_size_invariant:
  assumes fin:"finite (carrier G)"
  assumes P:"P \<in> subgroups_of_size p"
  assumes g:"g \<in> carrier G"
  shows "conjugation_action p g P \<in> subgroups_of_size p"
proof -
  from g have invg:"inv g \<in> carrier G" by (metis inv_closed)
  from P have PG:"subgroup P G" and card:"card P = p" unfolding subgroups_of_size_def by simp+
  hence PsubG:"P \<subseteq> carrier G" by (metis subgroup_imp_subset)
  hence PinvgsubG:"P #> inv g \<subseteq> carrier G" by (metis invg r_coset_subset_G)
  have " g <# (P #> inv g) \<in> subgroups_of_size p"
  proof(auto simp add:subgroups_of_size_def)
    show "subgroup (g <# (P #> inv g)) G" by (metis g PG conjugation_subgroup)
  next
    from card PsubG fin invg have "card (P #> inv g) = p" by (metis cardeq_rcoset)
    with g PinvgsubG fin show "card (g <# (P #> inv g)) = p" by (metis cardeq_lcoset)
  qed
  with P g show ?thesis unfolding conjugation_action_def by simp
qed

lemma (in group) conjugation_is_Bij:
  assumes fin:"finite (carrier G)"
  assumes g:"g \<in> carrier G"
  shows "conjugation_action p g \<in> Bij (subgroups_of_size p)"
proof -
  from g have invg:"inv g \<in> carrier G" by (rule inv_closed)
  from g have "conjugation_action p g \<in> extensional (subgroups_of_size p)" unfolding conjugation_action_def by simp
  moreover 
  have "bij_betw (conjugation_action p g) (subgroups_of_size p) (subgroups_of_size p)"
  proof(auto simp add:bij_betw_def)
    show "inj_on (conjugation_action p g) (subgroups_of_size p)"
    proof(rule inj_onI)
      fix U V
      assume U:"U \<in> subgroups_of_size p" and V:"V \<in> subgroups_of_size p"
      hence subsetG:"U \<subseteq> carrier G" "V \<subseteq> carrier G" unfolding subgroups_of_size_def by (metis (lifting) mem_Collect_eq subgroup_imp_subset)+
      hence subsetL:"U #> inv g \<subseteq> carrier G" "V #> inv g \<subseteq> carrier G" by (metis invg r_coset_subset_G)+
      assume "conjugation_action p g U = conjugation_action p g V"
      with g U V have "g <# (U #> inv g) = g <# (V #> inv g)" unfolding conjugation_action_def by simp
      hence "(inv g) <# (g <# (U #> inv g)) = (inv g) <# (g <# (V #> inv g))" by simp
      hence "(inv g \<otimes> g) <# (U #> inv g) = (inv g \<otimes> g) <# (V #> inv g)" by (metis g invg lcos_m_assoc r_coset_subset_G subsetG)
      hence "\<one> <# (U #> inv g) = \<one> <# (V #> inv g)" by (metis g l_inv)
      hence "U #> inv g = V #> inv g" by (metis subsetL lcos_mult_one)
      hence "(U #> inv g) #> g = (V #> inv g) #> g" by simp
      hence "U #> (inv g \<otimes> g) = V #> (inv g \<otimes> g)" by (metis g invg rcos_m_assoc subsetG) 
      hence "U #> \<one> = V #> \<one>" by (metis g l_inv)
      thus "U = V" by (metis subsetG rcos_mult_one)
    qed
  next
    fix P
    assume "P \<in> subgroups_of_size p"
    thus "conjugation_action p g P \<in> subgroups_of_size p" by (metis fin g conjugation_is_size_invariant)
  next
    fix P
    assume P:"P \<in> subgroups_of_size p"
    with invg have "conjugation_action p (inv g) P \<in> subgroups_of_size p" by (metis fin invg conjugation_is_size_invariant)
    with invg P have "(inv g) <# (P #> (inv (inv g))) \<in> subgroups_of_size p" unfolding conjugation_action_def by simp
    hence 1:"(inv g) <# (P #> g) \<in> subgroups_of_size p" by (metis g inv_inv)
    have "g <# (((inv g) <# (P #> g)) #> inv g) = (\<Union>p \<in> P. {g \<otimes> (inv g \<otimes> (p \<otimes> g) \<otimes> inv g)})" unfolding r_coset_def l_coset_def by (simp add:m_assoc)
    also from P have PG:"P \<subseteq> carrier G" unfolding subgroups_of_size_def by (auto simp add:subgroup_imp_subset)
    have "\<forall>p \<in> P.  g \<otimes> (inv g \<otimes> (p \<otimes> g) \<otimes> inv g) = p"
    proof(auto)
      fix p
      assume "p \<in> P"
      with PG have p:"p \<in> carrier G"..
      with g invg have "g \<otimes> (inv g \<otimes> (p \<otimes> g) \<otimes> inv g) = (g \<otimes> inv g) \<otimes> p \<otimes> (g \<otimes> inv g)" by (metis m_assoc m_closed)
      also with g invg g p have "... = p" by (metis l_one r_inv r_one)
      finally show "g \<otimes> (inv g \<otimes> (p \<otimes> g) \<otimes> inv g) = p". 
    qed
    hence "(\<Union>p \<in> P. {g \<otimes> (inv g \<otimes> (p \<otimes> g) \<otimes> inv g)}) = P" by simp
    finally have "g <# (((inv g) <# (P #> g)) #> inv g) = P".
    with 1 have "P \<in> (\<lambda>P. g <# (P #> inv g)) ` subgroups_of_size p" by auto
    with P g show "P \<in> conjugation_action p g ` subgroups_of_size p" unfolding conjugation_action_def by simp
  qed
  ultimately show ?thesis unfolding BijGroup_def Bij_def by simp
qed

lemma (in group) lr_coset_assoc:
  assumes g:"g \<in> carrier G"
  assumes h:"h \<in> carrier G"
  assumes P:"P \<subseteq> carrier G"
  shows "g <# (P #> h) = (g <# P) #> h"
proof(auto)
  fix x
  assume "x \<in> g <# (P #> h)"
  then obtain p where "p \<in> P" and p:"x = g \<otimes> (p \<otimes> h)" unfolding l_coset_def r_coset_def by auto
  with P have "p \<in> carrier G" by auto
  with g h p have "x = (g \<otimes> p) \<otimes> h" by (metis m_assoc)
  with `p \<in> P` show "x \<in> (g <# P) #> h" unfolding l_coset_def r_coset_def by auto
next
  fix x
  assume "x \<in> (g <# P) #> h"
  then obtain p where "p \<in> P" and p:"x = (g \<otimes> p) \<otimes> h" unfolding l_coset_def r_coset_def by auto
  with P have "p \<in> carrier G" by auto
  with g h p have "x = g \<otimes> (p \<otimes> h)" by (metis m_assoc)
  with `p \<in> P` show "x \<in> g <# (P #> h)" unfolding l_coset_def r_coset_def by auto
qed

lemma (in group) acts_on_subsets:
  assumes fin:"finite (carrier G)"
  shows "group_action G (conjugation_action p) (subgroups_of_size p)"
unfolding group_action_def group_action_axioms_def group_hom_def group_hom_axioms_def hom_def
apply(auto simp add:is_group group_BijGroup)
proof -
  fix g
  assume g:"g \<in> carrier G"
  with fin show "conjugation_action p g \<in> carrier (BijGroup (subgroups_of_size p))"
    unfolding BijGroup_def by (metis conjugation_is_Bij partial_object.select_convs(1))
next
  fix x y
  assume x:"x \<in> carrier G" and y:"y \<in> carrier G"
  hence invx:"inv x \<in> carrier G" and invy:"inv y \<in> carrier G" by (metis inv_closed)+
  from x y have xyG:"x \<otimes> y \<in> carrier G" by (metis m_closed)
  def conjx \<equiv> "conjugation_action p x"
  def conjy \<equiv> "conjugation_action p y"
  from fin x have xBij:"conjx \<in> Bij (subgroups_of_size p)" unfolding conjx_def by (metis conjugation_is_Bij)
  from fin y have yBij:"conjy \<in> Bij (subgroups_of_size p)" unfolding conjy_def by (metis conjugation_is_Bij)
  have "conjx \<otimes>\<^bsub>BijGroup (subgroups_of_size p)\<^esub> conjy
    = (\<lambda>g\<in>Bij (subgroups_of_size p). restrict (compose (subgroups_of_size p) g) (Bij (subgroups_of_size p))) conjx conjy" unfolding BijGroup_def by simp
  also from xBij yBij have "... = compose (subgroups_of_size p) conjx conjy" by simp
  also have "... = (\<lambda>P\<in>subgroups_of_size p. conjx (conjy P))" by (metis compose_def)
  also have "... = (\<lambda>P\<in>subgroups_of_size p. x \<otimes> y <# (P #> inv (x \<otimes> y)))"
  proof(rule restrict_ext)
    fix P
    assume P:"P \<in> subgroups_of_size p"
    hence PG:"P \<subseteq> carrier G" unfolding subgroups_of_size_def by (auto simp:subgroup_imp_subset)
    with y have yPG:"y <# P \<subseteq> carrier G" by (metis l_coset_subset_G)
    from x y have invxyG:"inv (x \<otimes> y) \<in> carrier G" and xyG:"x \<otimes> y \<in> carrier G" by (metis inv_closed m_closed)+
    from yBij have "conjy ` subgroups_of_size p = subgroups_of_size p" unfolding Bij_def bij_betw_def by simp
    with P have conjyP:"conjy P \<in> subgroups_of_size p" unfolding Bij_def bij_betw_def by (metis (full_types) imageI) 
    with x y P have "conjx (conjy P) = x <# ((y <# (P #> inv y)) #> inv x)" unfolding conjy_def conjx_def conjugation_action_def by simp
    also from y invy PG have "... = x <# (((y <# P) #> inv y) #> inv x)" by (metis lr_coset_assoc)
    also from PG invx invy y have "... = x <# ((y <# P) #> (inv y \<otimes> inv x))" by (metis l_coset_subset_G rcos_m_assoc)
    also from x y have "... = x <# ((y <# P) #> inv (x \<otimes> y))" by (metis inv_mult_group)
    also from invxyG x yPG have "... = (x <# (y <# P)) #> inv (x \<otimes> y)" by (metis lr_coset_assoc)
    also from x y PG have "... = ((x \<otimes> y) <# P) #> inv (x \<otimes> y)" by (metis lcos_m_assoc)
    also from xyG invxyG PG have "... = (x \<otimes> y) <# (P #> inv (x \<otimes> y))" by (metis lr_coset_assoc)
    finally show "conjx (conjy P) = x \<otimes> y <# (P #> inv (x \<otimes> y))".
  qed
  finally have "conjx \<otimes>\<^bsub>BijGroup (subgroups_of_size p)\<^esub> conjy = (\<lambda>P\<in>subgroups_of_size p. x \<otimes> y <# (P #> inv (x \<otimes> y)))".
  with xyG show "conjugation_action p (x \<otimes> y)
    = conjugation_action p x \<otimes>\<^bsub>BijGroup (subgroups_of_size p)\<^esub> conjugation_action p y"
    unfolding conjx_def conjy_def conjugation_action_def by simp
qed

lemma (in group) stabilizer_contains_P:
  assumes fin:"finite (carrier G)"
  assumes P:"P \<in> subgroups_of_size p"
  shows "P \<subseteq> group_action.stabilizer G (conjugation_action p) P"
proof
  from P have PG:"subgroup P G" unfolding subgroups_of_size_def by simp
  from fin interpret conj:group_action G "(conjugation_action p)" "(subgroups_of_size p)" by (rule acts_on_subsets)
  fix x
  assume x:"x \<in> P"
  with PG have "inv x \<in> P" by (metis subgroup.m_inv_closed) 
  from x P have xG:"x \<in> carrier G" unfolding subgroups_of_size_def subgroup_def by auto
  with P have "conjugation_action p x P = x <# (P #> inv x)" unfolding conjugation_action_def by simp
  also from `inv x \<in> P` PG have "... = x <# P" by (metis coset_join2 subgroup.mem_carrier)
  also from x PG have "... = P" by (metis lcoset_join2 subgroup.mem_carrier)
  finally have "conjugation_action p x P = P".
  with xG show "x \<in> group_action.stabilizer G (conjugation_action p) P" unfolding conj.stabilizer_def by simp
qed

corollary (in group) stabilizer_supergrp_P:
  assumes fin:"finite (carrier G)"
  assumes P:"P \<in> subgroups_of_size p"
  shows "subgroup P (G\<lparr>carrier := group_action.stabilizer G (conjugation_action p) P\<rparr>)"
proof -
  from assms have "P \<subseteq> group_action.stabilizer G (conjugation_action p) P" by (rule stabilizer_contains_P)
  moreover from P have "subgroup P G" unfolding subgroups_of_size_def by simp
  moreover from P fin have "subgroup (group_action.stabilizer G (conjugation_action p) P) G" by (metis acts_on_subsets group_action.stabilizer_is_subgroup)
  ultimately show ?thesis by (metis is_group subgroup.subgroup_of_subset)
qed

end