(*  Title:      Additional Facts about Subgroups and Normal Subgroups
    Author:     Jakob von Raumer, Karlsruhe Institute of Technology
    Maintainer: Jakob von Raumer <jakob.raumer@student.kit.edu>
*)

theory SubgroupsAndNormalSubgroups
imports
  "Coset"
  "SndSylow"
begin

section {* Preliminary lemmas *}

text {* A group of order 1 is always the trivial group. *}

lemma (in group) order_one_triv_iff:
  shows "(order G = 1) = (carrier G = {\<one>})"
proof
  assume "order G = 1"
  find_theorems "{?x}" "card ?y"
  with one_closed show "carrier G = {\<one>}" unfolding order_def sorry
next
  assume "carrier G = {\<one>}"
  thus "order G = 1" unfolding order_def by auto
qed

lemma (in group) finite_pos_order:
  assumes finite:"finite (carrier G)"
  shows "0 < order G"
proof -
  from one_closed finite show ?thesis unfolding order_def by (metis card_gt_0_iff subgroup_nonempty subgroup_self)
qed

section {* More Facts about Subgroups *}

lemma (in subgroup) subgroup_of_restricted_group:
  assumes "subgroup U (G\<lparr> carrier := H\<rparr>)"
  shows "U \<subseteq> H"
using assms subgroup_imp_subset by force

lemma (in subgroup) subgroup_of_subgroup:
  assumes "group G"
  assumes "subgroup U (G\<lparr> carrier := H\<rparr>)"
  shows "subgroup U G"
proof
  from assms(2) have "U \<subseteq> H" by (rule subgroup_of_restricted_group)
  thus "U \<subseteq> carrier G" by (auto simp:subset)
next
  fix x y
  have a:"x \<otimes> y = x \<otimes>\<^bsub>G\<lparr> carrier := H\<rparr>\<^esub> y" by simp
  assume "x \<in> U" "y \<in> U"
  with assms a show " x \<otimes> y \<in> U" by (metis subgroup.m_closed)
next
  have "\<one>\<^bsub>G\<lparr> carrier := H\<rparr>\<^esub> = \<one>" by simp
  with assms show "\<one> \<in> U" by (metis subgroup.one_closed)
next
  have "subgroup H G"..
  fix x
  assume "x \<in> U"
  with assms(2) have "inv\<^bsub>G\<lparr> carrier := H\<rparr>\<^esub> x \<in> U" by (rule subgroup.m_inv_closed)
  moreover from assms `x \<in> U` have "x \<in> H" by (metis in_mono subgroup_of_restricted_group)
  with assms(1) `subgroup H G` have "inv\<^bsub>G\<lparr> carrier := H\<rparr>\<^esub> x = inv x" by (rule group.subgroup_inv_equality)
  ultimately show "inv x \<in> U" by simp
qed

text {* Being a subgroup is preserved by surjective homomorphisms *}

lemma (in subgroup) surj_hom_subgroup:
  assumes \<phi>:"group_hom G F \<phi>"
  assumes \<phi>surj:"\<phi> ` (carrier G) = carrier F"
  shows "subgroup (\<phi> ` H) F"
proof
  from \<phi>surj show img_subset:"\<phi> ` H \<subseteq> carrier F" unfolding iso_def bij_betw_def by auto
next
  fix f f'
	assume h:"f \<in> \<phi> ` H" and h':"f' \<in> \<phi> ` H"
	with \<phi>surj obtain g g' where g:"g \<in> H" "f = \<phi> g" and g':"g' \<in> H" "f' = \<phi> g'" by auto
	hence "g \<otimes>\<^bsub>G\<^esub> g' \<in> H" by (metis m_closed)
  hence "\<phi> (g \<otimes>\<^bsub>G\<^esub> g') \<in> \<phi> ` H" by simp
  with g g' \<phi> show "f \<otimes>\<^bsub>F\<^esub> f' \<in> \<phi> ` H"  using group_hom.hom_mult by fastforce
next
  have "\<phi> \<one> \<in> \<phi> ` H" by auto
  with \<phi> show  "\<one>\<^bsub>F\<^esub> \<in> \<phi> ` H" by (metis group_hom.hom_one)
next
  fix f
  assume f:"f \<in> \<phi> ` H"
  then obtain g where g:"g \<in> H" "f = \<phi> g" by auto
  hence "inv g \<in> H" by auto
  hence "\<phi> (inv g) \<in> \<phi> ` H" by auto
  with \<phi> g subset show "inv\<^bsub>F\<^esub> f \<in> \<phi> ` H" using group_hom.hom_inv by fastforce
qed

text {* ... and thus of course by isomorphisms of groups. *}

lemma iso_subgroup:
  assumes groups:"group G" "group F"
  assumes HG:"subgroup H G"
  assumes \<phi>:"\<phi> \<in> G \<cong> F"
  shows "subgroup (\<phi> ` H) F"
proof -
  from groups \<phi> have "group_hom G F \<phi>" unfolding group_hom_def group_hom_axioms_def iso_def by auto
  moreover from \<phi> have "\<phi> ` (carrier G) = carrier F" unfolding iso_def bij_betw_def by simp
  moreover note HG
  ultimately show ?thesis by (metis subgroup.surj_hom_subgroup)
qed

text {* An isomorphism restricts to an isomorphism of subgroups. *}

lemma iso_restrict:
  assumes groups:"group G" "group F"
  assumes HG:"subgroup H G"
  assumes \<phi>:"\<phi> \<in> G \<cong> F"
  shows "(restrict \<phi> H) \<in> (G\<lparr>carrier := H\<rparr>) \<cong> (F\<lparr>carrier := \<phi> ` H\<rparr>)"
unfolding iso_def hom_def bij_betw_def inj_on_def
proof auto
  fix g h
  assume "g \<in> H" "h \<in> H"
  hence "g \<in> carrier G" "h \<in> carrier G" by (metis HG subgroup.mem_carrier)+
  thus "\<phi> (g \<otimes>\<^bsub>G\<^esub> h) = \<phi> g \<otimes>\<^bsub>F\<^esub> \<phi> h" using \<phi> unfolding iso_def hom_def by auto
next
  fix g h
  assume "g \<in> H" "h \<in> H" "g \<otimes>\<^bsub>G\<^esub> h \<notin> H"
  hence "False" using HG unfolding subgroup_def by auto
  thus "undefined = \<phi> g \<otimes>\<^bsub>F\<^esub> \<phi> h" by auto
next
  fix g h
  assume g:"g \<in> H" and h:"h \<in> H" and eq:"\<phi> g = \<phi> h"
  hence "g \<in> carrier G" "h \<in> carrier G" by (metis HG subgroup.mem_carrier)+
  with eq show "g = h" using \<phi> unfolding iso_def bij_betw_def inj_on_def by auto
qed

text {* The intersection of two subgroups is, again, a subgroup *}

lemma (in group) subgroup_intersect:
  assumes "subgroup H G"
  assumes "subgroup H' G"
  shows "subgroup (H \<inter> H') G"
using assms unfolding subgroup_def by auto

section {* Facts about Normal Subgroups *}

text {* Being a normal subgroup is preserved by surjective homomorphisms. *}

lemma (in normal) surj_hom_normal_subgroup:
  assumes \<phi>:"group_hom G F \<phi>"
  assumes \<phi>surj:"\<phi> ` (carrier G) = carrier F"
  shows "(\<phi> ` H) \<lhd> F"
proof (rule group.normalI)
  from \<phi> show "group F" unfolding group_hom_def group_hom_axioms_def by simp
next
  from \<phi> \<phi>surj show "subgroup (\<phi> ` H) F" by (rule surj_hom_subgroup)
next
  show "\<forall>x\<in>carrier F. \<phi> ` H #>\<^bsub>F\<^esub> x = x <#\<^bsub>F\<^esub> \<phi> ` H"
  proof
    fix f
    assume f:"f \<in> carrier F"
    with \<phi>surj obtain g where g:"g \<in> carrier G" "f = \<phi> g" by auto
    hence "\<phi> ` H #>\<^bsub>F\<^esub> f = \<phi> ` H #>\<^bsub>F\<^esub> \<phi> g" by simp
    also have "... = (\<lambda>x. (\<phi> x) \<otimes>\<^bsub>F\<^esub> (\<phi> g)) ` H" unfolding r_coset_def image_def by auto
    also have "... = (\<lambda>x. \<phi> (x \<otimes> g)) ` H" using subset g \<phi> group_hom.hom_mult unfolding image_def by fastforce
    also have "... = \<phi> ` (H #> g)" using \<phi> unfolding r_coset_def by auto
    also have "... = \<phi> ` (g <# H)" by (metis coset_eq g(1))
    also have "... = (\<lambda>x. \<phi> (g \<otimes> x)) ` H" using \<phi> unfolding l_coset_def by auto
    also have "... = (\<lambda>x. (\<phi> g) \<otimes>\<^bsub>F\<^esub> (\<phi> x)) ` H" using subset g \<phi> group_hom.hom_mult by fastforce
    also have "... = \<phi> g <#\<^bsub>F\<^esub> \<phi> ` H" unfolding l_coset_def image_def by auto
    also have "... = f <#\<^bsub>F\<^esub> \<phi> ` H" using g by simp
    finally show "\<phi> ` H #>\<^bsub>F\<^esub> f = f <#\<^bsub>F\<^esub> \<phi> ` H".
  qed
qed

text {* Being a normal subgroup is preserved by group isomorphisms. *}

lemma iso_normal_subgroup:
  assumes groups:"group G" "group F"
  assumes HG:"H \<lhd> G"
  assumes \<phi>:"\<phi> \<in> G \<cong> F"
  shows "(\<phi> ` H) \<lhd> F"
proof -
  from groups \<phi> have "group_hom G F \<phi>" unfolding group_hom_def group_hom_axioms_def iso_def by auto
  moreover from \<phi> have "\<phi> ` (carrier G) = carrier F" unfolding iso_def bij_betw_def by simp
  moreover note HG
  ultimately show ?thesis using normal.surj_hom_normal_subgroup by metis
qed

text {* The trivial subgroup is a subgroup: *}

lemma (in group) triv_subgroup:
  shows "subgroup {\<one>} G"
unfolding subgroup_def by auto

text {* The cardinality of the right cosets of the trivial subgroup is the cardinality of the group itself: *}

lemma (in group) card_rcosets_triv:
  assumes "finite (carrier G)"
  shows "card (rcosets {\<one>}) = order G"
proof -
  have "subgroup {\<one>} G" by (rule triv_subgroup)
  with assms have "card (rcosets {\<one>}) * card {\<one>} = order G" by (rule lagrange)
  thus ?thesis by (auto simp:card_Suc_eq)
qed

text {* The intersection of two normal subgroups is, again, a normal subgroup. *}

lemma (in group) normal_subgroup_intersect:
  assumes "M \<lhd> G" and "N \<lhd> G"
  shows "M \<inter> N \<lhd> G"
using assms subgroup_intersect is_group normal_inv_iff by simp

text {* A subgroup relation survives factoring by a normal subgroup. *}

lemma (in group) restrict_normality_to_subgroup:
  assumes "N \<lhd> G" and "N \<subseteq> H" and "subgroup H G"
  shows "N \<lhd> G\<lparr>carrier := H\<rparr>"
proof (rule group.normalI)
  show "group (G\<lparr>carrier := H\<rparr>)" by (metis assms(3) subgroup_imp_group)
next
  show "subgroup N (G\<lparr>carrier := H\<rparr>)"
    using assms is_group normal_imp_subgroup subgroup.subgroup_of_subset by blast
next
  show "\<forall>x\<in>carrier (G\<lparr>carrier := H\<rparr>). N #>\<^bsub>G\<lparr>carrier := H\<rparr>\<^esub> x = x <#\<^bsub>G\<lparr>carrier := H\<rparr>\<^esub> N"
    using assms(1,3) subgroup_imp_subset
    unfolding normal_def normal_axioms_def r_coset_def l_coset_def by fastforce
qed

lemma (in group) normal_subgroup_factorize:
  assumes "N \<lhd> G" and "N \<subseteq> H" and "subgroup H G"
  shows "subgroup (rcosets\<^bsub>G\<lparr>carrier := H\<rparr>\<^esub> N) (G Mod N)"
proof -
  have "N \<lhd> G\<lparr>carrier := H\<rparr>" using assms by (rule restrict_normality_to_subgroup)
  hence "group (G\<lparr>carrier := H\<rparr> Mod N)" by (rule normal.factorgroup_is_group)
  moreover have "carrier (G\<lparr>carrier := H\<rparr> Mod N) \<subseteq> carrier (G Mod N)" unfolding FactGroup_def RCOSETS_def
    using assms(3) subgroup_imp_subset sorry
  ultimately show ?thesis sorry
qed

text {* A normality relation survives factoring by a normal subgroup. *}

lemma (in group) normality_factorization:
  assumes "N \<lhd> G" and "N \<subseteq> H" and "H \<lhd> G"
  shows "(rcosets\<^bsub>G\<lparr>carrier := H\<rparr>\<^esub> N) \<lhd> (G Mod N)"
sorry

text {* Factoring by a normal subgroups yields the trivial group iff the subgroup is the whole group. *}

lemma (in normal) fact_group_trivial_iff:
  assumes "finite (carrier G)"
  shows "(carrier (G Mod H) = {\<one>\<^bsub>G Mod H\<^esub>}) = (H = carrier G)"
proof
  assume "carrier (G Mod H) = {\<one>\<^bsub>G Mod H\<^esub>}"
  moreover with assms lagrange have "order (G Mod H) * card H = order G" unfolding FactGroup_def order_def using is_subgroup by force
  ultimately have "card H = order G" unfolding order_def by auto
  thus "H = carrier G" using subgroup_imp_subset is_subgroup assms unfolding order_def by (metis card_eq_subset_imp_eq)
next
  from assms have ordergt0:"order G > 0" unfolding order_def by (metis subgroup.finite_imp_card_positive subgroup_self)
  assume "H = carrier G"
  hence "card H = order G" unfolding order_def by simp
  with assms is_subgroup lagrange have "card (rcosets H) * order G = order G" by metis
  with ordergt0 have "card (rcosets H) = 1" by (metis mult_eq_self_implies_10 nat_mult_commute neq0_conv)
  hence "order (G Mod H) = 1" unfolding order_def FactGroup_def by auto
  thus "carrier (G Mod H) = {\<one>\<^bsub>G Mod H\<^esub>}" using factorgroup_is_group by (metis group.order_one_triv_iff)
qed

text {* Finite groups have finite quotients. *}

lemma (in normal) factgroup_finite:
  assumes "finite (carrier G)"
  shows "finite (rcosets H)"
using assms unfolding RCOSETS_def by auto

text {* The union of all the cosets contained in a subgroup of a quotient group acts as a represenation for that subgroup. *}

lemma (in normal) factgroup_subgroup_union_subgroup:
  assumes "subgroup A (G Mod H)"
  shows "subgroup (\<Union>A) G" 
proof
  from assms show "\<Union>A \<subseteq> carrier G"
    using subgroup_imp_subset is_subgroup m_closed unfolding FactGroup_def RCOSETS_def r_coset_def
    by force
next
  fix x y
  assume x:"x \<in> \<Union>A" and y:"y \<in> \<Union>A"
  then obtain H' H'' where H'H'':"x \<in> H'" "H' \<in> A" "y \<in> H''" "H'' \<in> A" by auto
  hence "x \<otimes> y \<in> H' <#> H''" unfolding set_mult_def by auto
  moreover from H'H'' have "H' <#> H'' \<in> A" using assms subgroup.m_closed unfolding FactGroup_def by force
  ultimately show "x \<otimes> y \<in> \<Union>A" by auto
next
  have "H \<in> A" using assms unfolding FactGroup_def using subgroup.one_closed by force
  moreover have "\<one> \<in> H" by (metis is_subgroup subgroup.one_closed)
  ultimately show "\<one> \<in> \<Union>A" by (metis UnionI)
next
  fix x
  assume x:"x \<in> \<Union>A"
  then obtain H' where H':"x \<in> H'" "H' \<in> A" by auto
  hence "inv x \<in> set_inv H'" unfolding SET_INV_def by auto
  moreover from H' have "set_inv H' \<in> A" using assms inv_FactGroup by (metis subgroup.m_inv_closed subgroup.mem_carrier)
  ultimately show "inv x \<in> \<Union>A" by (metis UnionI)
qed

section  {* Flattening the type of group carriers *}

text {* Flattening here means to convert the type of group elements from 'a set to 'a.
This is possible whenever the empty set is not an element of the group. *}

definition flatten where
  "flatten (G::('a set, 'b) monoid_scheme) rep = \<lparr>carrier=(rep ` (carrier G)),
      mult=(\<lambda> x y. rep ((the_inv_into (carrier G) rep x) \<otimes>\<^bsub>G\<^esub> (the_inv_into (carrier G) rep y))), one=rep \<one>\<^bsub>G\<^esub> \<rparr>"

lemma flatten_set_group_hom:
  assumes group:"group G"
  assumes inj:"inj_on rep (carrier G)"
  shows "rep \<in> hom G (flatten G rep)"
unfolding hom_def
proof auto
  fix g
  assume g:"g \<in> carrier G"
  thus "rep g \<in> carrier (flatten G rep)" unfolding flatten_def by auto
next
  fix g h
  assume g:"g \<in> carrier G" and h:"h \<in> carrier G"
  hence "rep g \<in> carrier (flatten G rep)" "rep h \<in> carrier (flatten G rep)" unfolding flatten_def by auto
  hence "rep g \<otimes>\<^bsub>flatten G rep\<^esub> rep h
    = rep (the_inv_into (carrier G) rep (rep g) \<otimes>\<^bsub>G\<^esub> the_inv_into (carrier G) rep (rep h))" unfolding flatten_def by auto
  also have "\<dots> = rep (g \<otimes>\<^bsub>G\<^esub> h)" using inj g h by (metis the_inv_into_f_f)
  finally show "rep (g \<otimes>\<^bsub>G\<^esub> h) = rep g \<otimes>\<^bsub>flatten G rep\<^esub> rep h"..
qed

lemma flatten_set_group:
  assumes group:"group G"
  assumes inj:"inj_on rep (carrier G)"
  shows "group (flatten G rep)"
proof (rule groupI)
  fix x y
  assume x:"x \<in> carrier (flatten G rep)" and y:"y \<in> carrier (flatten G rep)"
  def g \<equiv> "the_inv_into (carrier G) rep x" and h \<equiv> "the_inv_into (carrier G) rep y"
  hence "x \<otimes>\<^bsub>flatten G rep\<^esub> y = rep (g \<otimes>\<^bsub>G\<^esub> h)" unfolding flatten_def by auto
  moreover from g_def h_def have "g \<in> carrier G" "h \<in> carrier G" 
    using inj x y the_inv_into_into unfolding flatten_def by (metis partial_object.select_convs(1) subset_refl)+
  hence "g \<otimes>\<^bsub>G\<^esub> h \<in> carrier G" by (metis group group.is_monoid monoid.m_closed)
  hence "rep (g \<otimes>\<^bsub>G\<^esub> h) \<in> carrier (flatten G rep)" unfolding flatten_def by simp
  ultimately show "x \<otimes>\<^bsub>flatten G rep\<^esub> y \<in> carrier (flatten G rep)" by simp
next
  show "\<one>\<^bsub>flatten G rep\<^esub> \<in> carrier (flatten G rep)" unfolding flatten_def by (simp add: group group.is_monoid)
next
  fix x y z
  assume x:"x \<in> carrier (flatten G rep)" and y:"y \<in> carrier (flatten G rep)" and z:"z \<in> carrier (flatten G rep)"
  def g \<equiv> "the_inv_into (carrier G) rep x" and h \<equiv> "the_inv_into (carrier G) rep y" and k \<equiv> "the_inv_into (carrier G) rep z"
  hence "x \<otimes>\<^bsub>flatten G rep\<^esub> y \<otimes>\<^bsub>flatten G rep\<^esub> z = (rep (g \<otimes>\<^bsub>G\<^esub> h)) \<otimes> \<^bsub>flatten G rep\<^esub> z" unfolding flatten_def by auto
  also have "\<dots> = rep (the_inv_into (carrier G) rep (rep (g \<otimes>\<^bsub>G\<^esub> h)) \<otimes>\<^bsub>G\<^esub> k)" using k_def unfolding flatten_def by auto
  also from g_def h_def k_def have ghkG:"g \<in> carrier G" "h \<in> carrier G" "k \<in> carrier G"
    using inj x y z the_inv_into_into unfolding flatten_def by fastforce+
  hence gh:"g \<otimes>\<^bsub>G\<^esub> h \<in> carrier G" and hk:"h \<otimes>\<^bsub>G\<^esub> k \<in> carrier G" by (metis group group.is_monoid monoid.m_closed)+
  hence "rep (the_inv_into (carrier G) rep (rep (g \<otimes>\<^bsub>G\<^esub> h)) \<otimes>\<^bsub>G\<^esub> k) = rep ((g \<otimes>\<^bsub>G\<^esub> h) \<otimes>\<^bsub>G\<^esub> k)"
    unfolding flatten_def using inj the_inv_into_f_f by fastforce
  also have "\<dots> = rep (g \<otimes>\<^bsub>G\<^esub> (h \<otimes>\<^bsub>G\<^esub> k))" using group group.is_monoid ghkG monoid.m_assoc by fastforce
  also have "\<dots> = x \<otimes>\<^bsub>flatten G rep\<^esub> (rep (h \<otimes>\<^bsub>G\<^esub> k))" unfolding g_def flatten_def using hk inj the_inv_into_f_f by fastforce
  also have "\<dots> = x \<otimes>\<^bsub>flatten G rep\<^esub> (y \<otimes>\<^bsub>flatten G rep\<^esub> z)" unfolding h_def k_def flatten_def using x y by force
  finally show "x \<otimes>\<^bsub>flatten G rep\<^esub> y \<otimes>\<^bsub>flatten G rep\<^esub> z = x \<otimes>\<^bsub>flatten G rep\<^esub> (y \<otimes>\<^bsub>flatten G rep\<^esub> z)".
next
  fix x
  assume x:"x \<in> carrier (flatten G rep)"
  def g \<equiv> "the_inv_into (carrier G) rep x"
  hence gG:"g \<in> carrier G" using inj x unfolding flatten_def using the_inv_into_into by force
  have "\<one>\<^bsub>G\<^esub> \<in> (carrier G)" by (simp add: group group.is_monoid)
  hence "the_inv_into (carrier G) rep (\<one>\<^bsub>flatten G rep\<^esub>) = \<one>\<^bsub>G\<^esub>" unfolding flatten_def using the_inv_into_f_f inj by force
  hence "\<one>\<^bsub>flatten G rep\<^esub> \<otimes>\<^bsub>flatten G rep\<^esub> x = rep (\<one>\<^bsub>G\<^esub> \<otimes>\<^bsub>G\<^esub> g)" unfolding flatten_def g_def by simp
  also have "\<dots> = rep g" using gG group by (metis group.is_monoid monoid.l_one)
  also have "\<dots> = x" unfolding g_def using inj x f_the_inv_into_f unfolding flatten_def by force
  finally show "\<one>\<^bsub>flatten G rep\<^esub> \<otimes>\<^bsub>flatten G rep\<^esub> x = x".
next
  from group inj have hom:"rep \<in> hom G (flatten G rep)" using flatten_set_group_hom by auto
  fix x
  assume x:"x \<in> carrier (flatten G rep)"
  def g \<equiv> "the_inv_into (carrier G) rep x"
  hence gG:"g \<in> carrier G" using inj x unfolding flatten_def using the_inv_into_into by force
  hence invG:"inv\<^bsub>G\<^esub> g \<in> carrier G" by (metis group group.inv_closed)
  hence "rep (inv\<^bsub>G\<^esub> g) \<in> carrier (flatten G rep)" unfolding flatten_def by auto
  moreover have "rep (inv\<^bsub>G\<^esub> g) \<otimes>\<^bsub>flatten G rep\<^esub> x = rep (inv\<^bsub>G\<^esub> g) \<otimes>\<^bsub>flatten G rep\<^esub> (rep g)"
    unfolding g_def using f_the_inv_into_f inj x unfolding flatten_def by fastforce
  hence "rep (inv\<^bsub>G\<^esub> g) \<otimes>\<^bsub>flatten G rep\<^esub> x = rep (inv\<^bsub>G\<^esub> g \<otimes>\<^bsub>G\<^esub> g)"
    using hom unfolding hom_def using gG invG hom_def by auto
  hence "rep (inv\<^bsub>G\<^esub> g) \<otimes>\<^bsub>flatten G rep\<^esub> x = rep \<one>\<^bsub>G\<^esub>" using invG gG by (metis group group.l_inv)
  hence "rep (inv\<^bsub>G\<^esub> g) \<otimes>\<^bsub>flatten G rep\<^esub> x = \<one>\<^bsub>flatten G rep\<^esub>" unfolding flatten_def by auto
  ultimately show "\<exists>y\<in>carrier (flatten G rep). y \<otimes>\<^bsub>flatten G rep\<^esub> x = \<one>\<^bsub>flatten G rep\<^esub>" by auto
qed

lemma (in normal) flatten_set_group_mod_inj:
  shows "inj_on (\<lambda>U. SOME g. g \<in> U) (carrier (G Mod H))"
proof (rule inj_onI)
  fix U V
  assume U:"U \<in> carrier (G Mod H)" and V:"V \<in> carrier (G Mod H)"
  then obtain g h where g:"U = H #> g" "g \<in> carrier G" and h:"V = H #> h" "h \<in> carrier G"
    unfolding FactGroup_def RCOSETS_def by auto
  hence notempty:"U \<noteq> {}" "V \<noteq> {}" by (metis empty_iff is_subgroup rcos_self)+
  assume "(SOME g. g \<in> U) = (SOME g. g \<in> V)"
  with notempty have "(SOME g. g \<in> U) \<in> U \<inter> V" by (metis IntI ex_in_conv someI)
  thus "U = V" by (metis Int_iff g h is_subgroup repr_independence)
qed

lemma (in normal) flatten_set_group_mod:
  shows "group (flatten (G Mod H) (\<lambda>U. SOME g. g \<in> U))"
using factorgroup_is_group flatten_set_group_mod_inj by (rule flatten_set_group)

lemma (in normal) flatten_set_group_mod_iso:
  shows "(\<lambda>U. SOME g. g \<in> U) \<in> (G Mod H) \<cong> (flatten (G Mod H) (\<lambda>U. SOME g. g \<in> U))"
unfolding iso_def bij_betw_def
apply (auto)
 apply (metis flatten_set_group_mod_inj factorgroup_is_group flatten_set_group_hom)
 apply (rule flatten_set_group_mod_inj)
 unfolding flatten_def apply (auto)
done

end
