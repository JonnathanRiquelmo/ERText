package org.xtext.unipampa.erdsl.generator

import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import java.util.ArrayList
import org.xtext.unipampa.erdsl.erDsl.ERModel
import org.xtext.unipampa.erdsl.erDsl.Entity
import org.xtext.unipampa.erdsl.erDsl.Relation
import org.xtext.unipampa.erdsl.erDsl.Attribute

class MysqlFileGenerator extends AbstractGenerator {
	
	val myListFKs = new ArrayList();
	var globalFKcounter_1to1 = 0;
	var globalFKcounter_1toN = 0;
	var counter = 0; 
	var AuxCounterA = 0;
	var AuxCounterB = 0;
	var boolean auxT1 = false;
	var boolean auxT2 = false;
	var StringBuilder stringBuilderAlterTblNtoN = new StringBuilder;
	var StringBuilder stringBuilderAlterTblTernary = new StringBuilder;
	
	
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {

		val modeloER = input.contents.get(0) as ERModel
		
		fsa.generateFile('MySQL_' + modeloER.domain.name + '.sql', mySQLCreate(modeloER))
		
	}
	
	
		/**
	 * PHYSICAL SCHEMA (MySQL) GENERATOR CODE
	 */
	def mySQLCreate(ERModel e) '''
/* MySQL TEMPLATE GENERATED BY ERtext */
	
-- Database: «e.domain.name.toUpperCase»	
-- DROP DATABASE «e.domain.name.toUpperCase»;
CREATE DATABASE IF NOT EXISTS «e.domain.name.toUpperCase»;
 «var ListExendPKsLenght = 0»

/* --------------------------------- */
/*  1 to 1 and 1 to N RELATIONSHIPS  */
/* --------------------------------- */

	«FOR entity : e.entities SEPARATOR "\n);\n" AFTER ");\n"»
		«val myListPKs = newArrayList()»
		«val myListExtendPKs = newArrayList()»
		«mySQLHaveFK(e,entity)»
«««		FK SIMPLES É VAZIO para a entidade «entity.name»? «myListFKs.isNullOrEmpty»
«««		«IF myListFKs.isNullOrEmpty»-- SEM DEPENDENCIA
«««		ESSA ENTIDADE NÃO TEM FK SIMPLES: «entity.name»
-- Table: «entity.name.toUpperCase»
«IF !entity.generalization.isNullOrEmpty»-- Generalization/Specialization «entity.generalization.toString.toUpperCase» from table «entity.is.toString.toUpperCase»«ENDIF»
-- DROP TABLE «entity.name.toUpperCase»;	
CREATE TABLE IF NOT EXISTS «entity.name.toLowerCase» (
	«IF !(entity.is === null)»«FOR aux : e.entities»«IF aux.name.equalsIgnoreCase(entity.is.toString)»«FOR auxAttributes : aux.attributes»«IF auxAttributes.isIsKey»«mySQLAttTypeChecker(auxAttributes)»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»
	«FOR attribute : entity.attributes»«mySQLAttTypeChecker(attribute)»«ENDFOR»
		«IF !(entity.is === null)»«FOR aux : e.entities»«IF aux.name.equalsIgnoreCase(entity.is.toString)»«FOR auxAttributes : aux.attributes»«IF auxAttributes.isIsKey»
	«{myListPKs.add(auxAttributes.name.toLowerCase);""}»«{myListExtendPKs.add(auxAttributes.name.toLowerCase);""}»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»
	«FOR attribute : entity.attributes»«IF attribute.isIsKey»«{myListPKs.add(attribute.name.toString);""}»«ENDIF»«ENDFOR»
	«mySQLVerifyFKsAttributesRelation1to1(e, entity.name)»
	«mySQLVerifyFKsAttributesRelation1toN(e, entity.name)»
	CONSTRAINT pk_«entity.name.toLowerCase» PRIMARY KEY («FOR x : myListPKs SEPARATOR ", " AFTER ")"»«println(x.toLowerCase)»«ENDFOR»
«««			«IF !myListExtendPKs.nullOrEmpty || !myListFKs.isNullOrEmpty»,«ENDIF»
«««			«{ListExendPKsLenght = myListExtendPKs.size; null}»
«««			«FOR x : myListExtendPKs SEPARATOR ",\n"»FOREIGN KEY («println(x.toString.toLowerCase)») REFERENCES «mySQLDiscoverInheritedPKtoFK(e,x.toString, ListExendPKsLenght, entity.name)»«ENDFOR»«myListPKs.clear»«myListExtendPKs.clear»«myListFKs.clear»
«««			«{mySQL_COUNT_FKsRelation1to1(e, entity.name); null}»«{counter = globalFKcounter_1to1; AuxCounterA = globalFKcounter_1to1; null}» «{globalFKcounter_1to1 = 0;null}»
«««			«mySQLDefineFKsRelation1to1(e, entity.name, counter)»«{counter = 0;null}»«{mySQL_COUNT_FKsRelation1toN(e, entity.name); null}»«{counter = globalFKcounter_1toN; AuxCounterB = globalFKcounter_1toN; null}»«{globalFKcounter_1toN = 0;null}»«IF AuxCounterA > 0 && AuxCounterB > 0»,«ENDIF»«{AuxCounterA = 0;null}»«{AuxCounterB = 0;null}»
«««			«mySQLDefineFKsRelation1toN(e, entity.name, counter)» «{counter = 0;null}»
«««			!!! «myAlterTableFK(e, myListExtendPKs, ListExendPKsLenght, myListPKs)» !!!
«««	«ENDIF»
«««	«IF myListFKs.isNullOrEmpty»«println»);«println»«ENDIF»«myListFKs.clear»
	«ENDFOR»

/* ---------------------- */
/*  N to N RELATIONSHIPS  */
/* ---------------------- */ 

	«FOR relation : e.relations»
«val myListPKsFKs = newArrayList()»
		«IF ((relation.leftEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:N)'))
		&& 
		(relation.rightEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:N)')))»		
		«IF relation.name.nullOrEmpty»«relation.leftEnding.target.toString.toUpperCase»
			
-- Table: «relation.rightEnding.target.toString.toUpperCase»
-- DROP TABLE «relation.rightEnding.target.toString.toUpperCase»;
CREATE TABLE IF NOT EXISTS «relation.rightEnding.target.toString.toUpperCase» (
			«ELSEIF !relation.name.nullOrEmpty»
			
-- Table: «relation.name.toUpperCase»
-- DROP TABLE «relation.name.toUpperCase»;
CREATE TABLE IF NOT EXISTS «relation.name.toLowerCase» («ENDIF»
	«FOR entity : e.entities»
«IF relation.leftEnding.target.toString.equalsIgnoreCase(entity.name) && (relation.leftEnding.target.toString !== relation.rightEnding.target.toString)»«{myListPKsFKs.add(relation.leftEnding.target.toString);""}»«relation.leftEnding.target.toString.toLowerCase»«mySQLAttTypeCheckerNtoNLeft(e,relation)»«ENDIF»
	«IF relation.rightEnding.target.toString.equalsIgnoreCase(entity.name) && (relation.rightEnding.target.toString !== relation.leftEnding.target.toString)»«{myListPKsFKs.add(relation.rightEnding.target.toString);""}»«relation.rightEnding.target.toString.toLowerCase»«mySQLAttTypeCheckerNtoNRight(e,relation)»«ENDIF»
	«IF relation.leftEnding.target.toString.equalsIgnoreCase(entity.name) && (relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString))»«{myListPKsFKs.add(relation.leftEnding.target.toString);""}»«relation.leftEnding.target.toString.toLowerCase»_«relation.name.toLowerCase»_1«{auxT1 = true; null}»«mySQLAttTypeCheckerNtoNLeft(e,relation)»«ENDIF»
	«IF relation.rightEnding.target.toString.equalsIgnoreCase(entity.name) && (relation.rightEnding.target.toString.equalsIgnoreCase(relation.leftEnding.target.toString))»«{myListPKsFKs.add(relation.rightEnding.target.toString);""}»«relation.rightEnding.target.toString.toLowerCase»_«relation.name.toLowerCase»_2«{auxT2 = true; null}»«mySQLAttTypeCheckerNtoNRight(e,relation)»«ENDIF»
	«ENDFOR»«var iterCounter = 1»
	«IF !relation.attributes.nullOrEmpty»«FOR aux : relation.attributes»«mySQLAttTypeChecker(aux)»«ENDFOR»«ENDIF»
	CONSTRAINT pk_«relation.name.toLowerCase» PRIMARY KEY («FOR aux : relation.attributes»«IF aux.isIsKey»«aux.name.toString.toLowerCase», «ENDIF»«ENDFOR»«FOR x : myListPKsFKs SEPARATOR ", " AFTER ")"»«println(x.toLowerCase)»«IF auxT1 && auxT2»_«relation.name.toLowerCase»_«iterCounter++»«ENDIF»«ENDFOR»
	«val ListPKsFKsLenght = myListPKsFKs.size»«{iterCounter = 1; null}»
	«{stringBuilderAlterTblNtoN.append(mySQLAlterTableFK_0N_0N(myListPKsFKs, ListPKsFKsLenght, auxT1, auxT2, relation, iterCounter, e)); null}»
«««	«myAlterTableFK_0N_0N(myListPKsFKs, ListPKsFKsLenght, auxT1, auxT2, relation, iterCounter, e)»
«««	«FOR x : myListPKsFKs SEPARATOR "),\n"»FOREIGN KEY («println(x.toString.toLowerCase)»«IF auxT1 && auxT2»_«relation.name.toLowerCase»_«iterCounter++»«ENDIF») REFERENCES «print(x.toString.toLowerCase)» («mySQLDiscoverPKtoFK(e,x, ListPKsFKsLenght)»«mySQLDiscoverAutoInheritedPKtoFK(e,x)»«ENDFOR»)«myListPKsFKs.clear»
«««);
«{iterCounter = 1; null}»«{auxT1 = false; null}»«{auxT2 = false; null}»
);
		«ENDIF»
	«ENDFOR»

/* ----------------------- */
/*  TERNARY RELATIONSHIPS  */
/* ----------------------- */

	«var String artificialEntName1»«var String artificialEntKey1»«var String artificialEntKeyAlt1»
	«var String artificialEntName2»«var String artificialEntKey2»«var String artificialEntKeyAlt2»
	«var String realEntName»«var String realEntKey»
	«FOR relation : e.relations»
		«IF ((relation.leftEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:N)'))
		&& 
		(relation.rightEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:N)')))»
				«FOR aux : e.relations»
					«IF (!relation.name.nullOrEmpty) && (relation.name.equals(aux.leftEnding.target.toString))»
-- Table: «aux.name.toUpperCase»
-- DROP TABLE «aux.name.toUpperCase»;
CREATE TABLE IF NOT EXISTS «aux.name.toLowerCase» (	
	«FOR entAux : e.entities»
		«IF entAux.name.toString.equalsIgnoreCase(aux.rightEnding.target.toString)» 
			«FOR attAux : entAux.attributes»
				«IF attAux.isIsKey»
					«mySQLAttTypeChecker(attAux)»«{realEntName = entAux.name.toString.toLowerCase; null}»«{realEntKey = attAux.name.toString.toLowerCase; null}»
				«ENDIF»
			«ENDFOR»
		«ENDIF»
	«ENDFOR»
	«FOR relEntArtifial1 : e.relations»
		«IF relEntArtifial1.name.equalsIgnoreCase(aux.leftEnding.target.toString)»
			«FOR ent1 : e.entities»
				«IF ent1.name.equalsIgnoreCase(relEntArtifial1.leftEnding.target.toString)»
					«FOR ent1Att : ent1.attributes»
						«IF ent1Att.isIsKey»
							«mySQLAttTypeChecker(ent1Att)»«{artificialEntName1 = aux.leftEnding.target.toString.toLowerCase; null}»«{artificialEntKey1 = ent1Att.name.toString.toLowerCase; null}»«{artificialEntKeyAlt1 = ent1.name.toString.toLowerCase; null}»
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDFOR»
			«FOR ent2 : e.entities»
				«IF ent2.name.equalsIgnoreCase(relEntArtifial1.rightEnding.target.toString)»
					«FOR ent2Att : ent2.attributes»
						«IF ent2Att.isIsKey»
							«mySQLAttTypeChecker(ent2Att)»«{artificialEntName2 = aux.leftEnding.target.toString.toLowerCase; null}»«{artificialEntKey2 = ent2Att.name.toString.toLowerCase; null}»«{artificialEntKeyAlt2 = ent2.name.toString.toLowerCase; null}»
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDFOR»
		«ENDIF»
	«ENDFOR»
	«FOR aux2 : e.entities»
	«IF aux.rightEnding.target.toString.equalsIgnoreCase(aux2.name)»
	«FOR attribute : aux.attributes»«IF !attribute.name.nullOrEmpty && attribute.isIsKey»«mySQLAttTypeChecker(attribute)»«ENDIF»«ENDFOR»
	«FOR attribute : aux.attributes»«IF !attribute.name.nullOrEmpty && !attribute.isIsKey»«mySQLAttTypeChecker(attribute)»«ENDIF»«ENDFOR»
	«ENDIF»
«ENDFOR»
	CONSTRAINT pk_«aux.name.toLowerCase» PRIMARY KEY («realEntKey.toString», «artificialEntKey1», «artificialEntKey2.toString»)
	FOREIGN KEY («realEntKey.toString») REFERENCES «realEntName.toString» («realEntKey.toString»);
	FOREIGN KEY («artificialEntKey1.toString», «artificialEntKey2.toString») REFERENCES «artificialEntName1» («artificialEntKeyAlt1.toString», «artificialEntKeyAlt2.toString»);
«««	FOREIGN KEY («artificialEntKey2.toString») REFERENCES «artificialEntName2» («artificialEntKeyAlt2.toString»)
);
	«ELSEIF (!relation.name.nullOrEmpty) && (relation.name.equals(aux.rightEnding.target.toString))»
						
-- Table: «aux.name.toUpperCase»
-- DROP TABLE «aux.name.toUpperCase»;
CREATE TABLE IF NOT EXISTS «aux.name.toLowerCase» (
	«FOR entAux : e.entities»
		«IF entAux.name.toString.equalsIgnoreCase(aux.leftEnding.target.toString)» 
			«FOR attAux : entAux.attributes»
				«IF attAux.isIsKey»
					«mySQLAttTypeChecker(attAux)»«{realEntName = entAux.name.toString.toLowerCase; null}»«{realEntKey = attAux.name.toString.toLowerCase; null}»
				«ENDIF»
			«ENDFOR»
		«ENDIF»
	«ENDFOR»
	«FOR relEntArtifial1 : e.relations»
		«IF relEntArtifial1.name.equalsIgnoreCase(aux.rightEnding.target.toString)»
			«FOR ent1 : e.entities»
				«IF ent1.name.equalsIgnoreCase(relEntArtifial1.rightEnding.target.toString)»
					«FOR ent1Att : ent1.attributes»
						«IF ent1Att.isIsKey»
							«mySQLAttTypeChecker(ent1Att)»«{artificialEntName1 = aux.rightEnding.target.toString.toLowerCase; null}»«{artificialEntKey1 = ent1Att.name.toString.toLowerCase; null}»«{artificialEntKeyAlt1 = ent1.name.toString.toLowerCase; null}»
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDFOR»
			«FOR ent2 : e.entities»
				«IF ent2.name.equalsIgnoreCase(relEntArtifial1.leftEnding.target.toString)»
					«FOR ent2Att : ent2.attributes»
						«IF ent2Att.isIsKey»
							«mySQLAttTypeChecker(ent2Att)»«{artificialEntName2 = aux.rightEnding.target.toString.toLowerCase; null}»«{artificialEntKey2 = ent2Att.name.toString.toLowerCase; null}»«{artificialEntKeyAlt2 = ent2.name.toString.toLowerCase; null}»
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDFOR»
		«ENDIF»
	«ENDFOR»
	«FOR aux2 : e.entities»
	«IF aux.leftEnding.target.toString.equalsIgnoreCase(aux2.name)»
	«FOR attribute : aux.attributes»«IF !attribute.name.nullOrEmpty && attribute.isIsKey»«mySQLAttTypeChecker(attribute)»«ENDIF»«ENDFOR»
	«FOR attribute : aux.attributes»«IF !attribute.name.nullOrEmpty && !attribute.isIsKey»«mySQLAttTypeChecker(attribute)»«ENDIF»«ENDFOR»
	«ENDIF»
«ENDFOR»
	CONSTRAINT pk_«aux.name.toLowerCase» PRIMARY KEY («realEntKey.toString», «artificialEntKey1», «artificialEntKey2.toString»)
	«{stringBuilderAlterTblTernary.append( "ALTER TABLE public."+aux.name.toLowerCase+" ADD CONSTRAINT fk_"+aux.name.toLowerCase+"_"+realEntName.toString+" FOREIGN KEY ("+realEntKey.toString+") REFERENCES public."+realEntName.toString+" ("+realEntKey.toString+");"+println("\n")); null}»
	«{stringBuilderAlterTblTernary.append( "ALTER TABLE public."+aux.name.toLowerCase+" ADD CONSTRAINT fk_"+aux.name.toLowerCase+"_"+artificialEntName1+" FOREIGN KEY ("+artificialEntKey1.toString+", "+artificialEntKey2.toString+") REFERENCES public."+artificialEntName1+" ("+artificialEntKeyAlt1.toString+", "+artificialEntKeyAlt2.toString+");"); null}»
«««	ALTER TABLE public.«aux.name.toLowerCase» ADD CONSTRAINT fk_«aux.name.toLowerCase»_«realEntName.toString» FOREIGN KEY («realEntKey.toString») REFERENCES public.«realEntName.toString» («realEntKey.toString»);
«««	ALTER TABLE public.«aux.name.toLowerCase» ADD CONSTRAINT fk_«aux.name.toLowerCase»_«artificialEntName1» FOREIGN KEY («artificialEntKey1.toString», «artificialEntKey2.toString») REFERENCES public.«artificialEntName1» («artificialEntKeyAlt1.toString», «artificialEntKeyAlt2.toString»);
«««	FOREIGN KEY («artificialEntKey2.toString») REFERENCES «artificialEntName2» («artificialEntKeyAlt2.toString»)
);
				«ENDIF»
			«ENDFOR»
		«ENDIF»
	«ENDFOR»

/* ----------- */
/* ALTER TABLE */
/* ----------- */
	
-- BEGINNING OF ALTER TABLE (0,1 -> 1,N)
«val myListPKs = newArrayList()»
«val myListExtendPKs = newArrayList()»
«mySQLAlterTableFK_01_0N(e, myListExtendPKs, ListExendPKsLenght, myListPKs)»
-- END OF ALTER TABLE	(0,1 -> 1,N)		
					
«IF !stringBuilderAlterTblNtoN.toString.nullOrEmpty»
-- BEGINNING OF ALTER TABLE (N -> N)
«stringBuilderAlterTblNtoN.toString»
-- END OF ALTER TABLE (N -> N)
«stringBuilderAlterTblNtoN.length = 0»
«ENDIF»

«IF !stringBuilderAlterTblTernary.toString.nullOrEmpty»
-- BEGINNING OF ALTER TABLE (TERNARY)
	«stringBuilderAlterTblTernary.toString»
-- END OF ALTER TABLE (TERNARY)
«stringBuilderAlterTblTernary.length = 0»	
«ENDIF»


	'''
	
	private def mySQLAlterTableFK_01_0N(ERModel e, ArrayList myListExtendPKs, int ListExendPKsLenght, ArrayList myListPKs)'''
	«FOR entity : e.entities»
		«IF !(entity.is === null)»«FOR aux : e.entities»«IF aux.name.equalsIgnoreCase(entity.is.toString)»«FOR auxAttributes : aux.attributes»«IF auxAttributes.isIsKey»
			«{myListPKs.add(auxAttributes.name.toLowerCase);""}»«{myListExtendPKs.add(auxAttributes.name.toLowerCase);""}»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»
		«FOR attribute : entity.attributes»«IF attribute.isIsKey»«{myListPKs.add(attribute.name.toString);""}»«ENDIF»«ENDFOR»
		«FOR x : myListExtendPKs SEPARATOR "\n"»	ALTER TABLE public.«entity.name.toString.toLowerCase» ADD CONSTRAINT fk_«entity.name.toString.toFirstUpper»InheritedPK FOREIGN KEY («println(x.toString.toLowerCase)») REFERENCES public.«mySQLDiscoverInheritedPKtoFK(e,x.toString, ListExendPKsLenght, entity.name)»;«ENDFOR»«myListPKs.clear»«myListExtendPKs.clear»«myListFKs.clear»
			«{mySQL_COUNT_FKsRelation1to1(e, entity.name); null}»«{counter = globalFKcounter_1to1; AuxCounterA = globalFKcounter_1to1; null}» «{globalFKcounter_1to1 = 0;null}»
			«mySQLDefineFKsRelation1to1(e, entity.name, counter)»«{counter = 0;null}»«{mySQL_COUNT_FKsRelation1toN(e, entity.name); null}»«{counter = globalFKcounter_1toN; AuxCounterB = globalFKcounter_1toN; null}»«{globalFKcounter_1toN = 0;null}»
«««			«IF AuxCounterA > 0 && AuxCounterB > 0»,«ENDIF»«{AuxCounterA = 0;null}»«{AuxCounterB = 0;null}»
			«mySQLDefineFKsRelation1toN(e, entity.name, counter)» «{counter = 0;null}»
	«ENDFOR»
	'''
	
	private def mySQLAlterTableFK_0N_0N (ArrayList myListPKsFKs, int ListPKsFKsLenght, boolean auxT1, boolean auxT2, Relation relation, int iterCounter, ERModel e) '''
	 «var counterAux = iterCounter»
	 «FOR x : myListPKsFKs SEPARATOR ");\n" AFTER ");\n"»	ALTER TABLE public.«relation.name.toLowerCase» ADD CONSTRAINT fk_«relation.name.toLowerCase»_«println(x.toString.toLowerCase)»«IF auxT1 && auxT2»_«relation.name.toLowerCase»_«counterAux»«ENDIF» FOREIGN KEY («println(x.toString.toLowerCase)»«IF auxT1 && auxT2»_«relation.name.toLowerCase»_«counterAux++»«ENDIF») REFERENCES public.«print(x.toString.toLowerCase)» («mySQLDiscoverPKtoFK(e,x.toString, ListPKsFKsLenght)»«mySQLDiscoverAutoInheritedPKtoFK(e,x.toString)»«ENDFOR»
	'''
	
	private def mySQLAttTypeChecker(Attribute a) '''
		«a.name.toLowerCase» «IF a.type.toString.equalsIgnoreCase("string")» VARCHAR (255) NOT NULL,
				«ELSEIF a.type.toString.equalsIgnoreCase("int")» INT NOT NULL,
				«ELSEIF a.type.toString.equalsIgnoreCase("datetime")» DATE NOT NULL,
				«ELSEIF a.type.toString.equalsIgnoreCase("money")» NUMERIC NOT NULL,
				«ELSEIF a.type.toString.equalsIgnoreCase("double")» FLOAT NOT NULL,
				«ELSEIF a.type.toString.equalsIgnoreCase("boolean")» BOOLEAN NOT NULL,
				«ELSEIF a.type.toString.equalsIgnoreCase("file")» BLOB,
				«ENDIF»'''
	
	private def mySQLAttTypeCheckerUnnamed(Attribute a) '''
		«IF a.type.toString.equalsIgnoreCase("string")» VARCHAR (255) NOT NULL,
		«ELSEIF a.type.toString.equalsIgnoreCase("int")» INT NOT NULL,
		«ELSEIF a.type.toString.equalsIgnoreCase("datetime")» DATE NOT NULL,
		«ELSEIF a.type.toString.equalsIgnoreCase("money")» NUMERIC NOT NULL,
		«ELSEIF a.type.toString.equalsIgnoreCase("double")» FLOAT NOT NULL,
		«ELSEIF a.type.toString.equalsIgnoreCase("boolean")» BOOLEAN NOT NULL,
		«ELSEIF a.type.toString.equalsIgnoreCase("file")» BLOB,
		«ENDIF»
	'''
	
	private def mySQLAttTypeCheckerNtoNLeft (ERModel e, Relation r)'''
		«FOR aux : e.entities»
			«IF aux.name.toString == r.leftEnding.target.toString»
				«FOR aux2 : aux.attributes»
					«IF aux2.isIsKey»
						«IF aux2.type.toString.equalsIgnoreCase("string")» VARCHAR (255) NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("int")» INT NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("datetime")» DATE NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("money")» NUMERIC NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("double")» FLOAT NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("boolean")» BOOLEAN NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("file")» BLOB,
						«ENDIF»
					«ENDIF»
				«ENDFOR»
			«ENDIF»
		«ENDFOR»
	'''
	
	private def mySQLAttTypeCheckerNtoNRight (ERModel e, Relation r)'''
		«FOR aux : e.entities»
			«IF aux.name.toString == r.rightEnding.target.toString»
				«FOR aux2 : aux.attributes»
					«IF aux2.isIsKey»
						«IF aux2.type.toString.equalsIgnoreCase("string")» VARCHAR (255) NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("int")» INT NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("datetime")» DATE NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("money")» NUMERIC NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("double")» REAL NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("boolean")» BOOLEAN NOT NULL,
						«ELSEIF aux2.type.toString.equalsIgnoreCase("file")» BLOB,
						«ENDIF»
					«ENDIF»
				«ENDFOR»
			«ENDIF»
		«ENDFOR»
	'''
	
	private def mySQLDiscoverPKtoFK (ERModel e, String r, int i)'''
		«FOR aux : e.entities»«IF aux.name.toString == r.toString»«FOR aux2 : aux.attributes»«IF aux2.isIsKey»«aux2.name.toString.toLowerCase»«ENDIF»«IF (i - 1) == 0»,«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»'''
	
	private def mySQLDiscoverAutoInheritedPKtoFK (ERModel e, String r) '''
		«FOR auxE : e.entities»«IF auxE.name.equalsIgnoreCase(r.toString)»«FOR auxE2 : e.entities»«IF auxE.is !== null && auxE2.name.toString.equalsIgnoreCase(auxE.is.toString)»«FOR auxAtt : auxE2.attributes»«IF auxAtt.isIsKey»«auxAtt.name.toString.toLowerCase»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»'''
	
	private def mySQLDiscoverInheritedPKtoFK (ERModel e, String r, int i, String isAutoRel)'''«var auxi = i»«FOR aux : e.entities»«FOR aux2 : aux.attributes»«IF aux2.name.toString.equalsIgnoreCase(r.toString) && aux2.isIsKey»«aux.name.toString.toLowerCase» («aux2.name.toString.toLowerCase»)«FOR rAux : e.relations»«IF ((rAux.leftEnding.cardinality.equalsIgnoreCase('(0:N)') || rAux.leftEnding.cardinality.equalsIgnoreCase('(1:N)'))	&& (rAux.rightEnding.cardinality.equalsIgnoreCase('(0:N)') || rAux.rightEnding.cardinality.equalsIgnoreCase('(1:N)')))»«IF isAutoRel.equalsIgnoreCase(rAux.leftEnding.target.toString) && isAutoRel.equalsIgnoreCase(rAux.rightEnding.target.toString)»«{auxi = auxi-1; null}»«ENDIF»«ENDIF»«ENDFOR»«IF (auxi - 1) == 0»,«ENDIF»«ENDIF»«ENDFOR»«ENDFOR»'''
	
	private def mySQLVerifyFKsAttributesRelation1to1 (ERModel e, String ename) '''
		«FOR relation : e.relations»
			«IF ((relation.leftEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:1)'))
		&& 
		(relation.rightEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:1)')))»
				«IF relation.rightEnding.target.toString.equalsIgnoreCase(ename)»
					«FOR aux : e.entities»
						«IF relation.leftEnding.target.toString.equalsIgnoreCase(aux.name)»
							«IF aux.is === null»
								«FOR aux2 : aux.attributes»
									«IF aux2.isIsKey»
									««« Casos FK1»»»
										«mySQLAttTypeChecker(aux2)» 
									«ENDIF»
								«ENDFOR»
							«ELSEIF !(aux.is === null)»
							««« Casos FK2»»»
								«FOR entityAux : e.entities»
									«IF entityAux.name.equalsIgnoreCase(aux.is.toString)»
										«FOR attAux : entityAux.attributes»
											«IF attAux.isIsKey»
												«mySQLAttTypeChecker(attAux)»
											«ENDIF»
										«ENDFOR»
									«ENDIF»
								«ENDFOR»
							«ENDIF»
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDIF»			
		«ENDFOR»
	'''
	
	private def mySQLVerifyFKsAttributesRelation1toN (ERModel e, String ename) '''
		«FOR relation : e.relations»
			«IF (((relation.leftEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:1)'))
					&& 
					(relation.rightEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:N)')))) 
					||
					(((relation.leftEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:N)'))
					&& 
					(relation.rightEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:1)'))))»	
				«IF relation.rightEnding.target.toString.equalsIgnoreCase(ename)»
					«FOR aux : e.entities»
						«IF relation.leftEnding.target.toString.equalsIgnoreCase(aux.name)»
							«IF aux.is === null»
								«FOR attTest : aux.attributes»
									«IF attTest.isIsKey»
									««« Casos FK3»»»
										«mySQLAttTypeChecker(attTest)» 
									«ENDIF»
								«ENDFOR»
							«ELSEIF !(aux.is === null)»
								«IF relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString)»
								««« Casos FK4»»»
									«relation.name.toString.toLowerCase» «FOR aux2 : e.entities»«IF aux2.name.equalsIgnoreCase(relation.leftEnding.target.toString)»«FOR aux3 : e.entities»«IF aux3.name.equalsIgnoreCase(aux2.is.toString)»«FOR aux4 : aux3.attributes»«IF aux4.isIsKey»«mySQLAttTypeCheckerUnnamed(aux4)»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»
								«ELSEIF !relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString)»
								««« Casos FK5»»»
									«relation.leftEnding.target.toString.toLowerCase» «FOR aux2 : e.entities»«IF aux2.name.equalsIgnoreCase(relation.leftEnding.target.toString)»«FOR aux3 : e.entities»«IF aux3.name.equalsIgnoreCase(aux2.is.toString)»«FOR aux4 : aux3.attributes»«IF aux4.isIsKey»«mySQLAttTypeCheckerUnnamed(aux4)»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»
								«ENDIF»
							«ENDIF»
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDIF»
		«ENDFOR»
	'''
	
	private def mySQL_COUNT_FKsRelation1to1(ERModel e, String ename) '''
	«FOR relation : e.relations»
				«IF ((relation.leftEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:1)'))
				&& 
				(relation.rightEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:1)')))»
					«IF relation.rightEnding.target.toString.equalsIgnoreCase(ename)»
						«FOR aux : e.entities»
							«IF relation.leftEnding.target.toString.equalsIgnoreCase(aux.name)»
								«IF aux.is === null»
									«FOR aux2 : aux.attributes»
										«IF aux2.isIsKey»
											«{globalFKcounter_1to1 += 1; null}»
										«ENDIF»
									«ENDFOR»
								«ELSEIF !(aux.is === null)»
									«{globalFKcounter_1to1 += 1; null}»
								«ENDIF»
							«ENDIF»
						«ENDFOR»
					«ENDIF»
				«ENDIF»			
			«ENDFOR»
«««========= TEM «globalFKcounter_1to1.toString» FKS 1 para 1 =========
	'''
	
	private def mySQLDefineFKsRelation1to1(ERModel e, String ename, int count) '''
		«FOR relation : e.relations»«IF ((relation.leftEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:1)')) && (relation.rightEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:1)')))»«IF relation.rightEnding.target.toString.equalsIgnoreCase(ename)»«FOR aux : e.entities»«IF relation.leftEnding.target.toString.equalsIgnoreCase(aux.name)»«IF aux.is === null»«FOR aux2 : aux.attributes»«IF aux2.isIsKey»ALTER TABLE public.«relation.rightEnding.target.toString.toLowerCase» ADD CONSTRAINT fk_«relation.rightEnding.target.toString.toFirstUpper»_«relation.leftEnding.target.toString.toFirstUpper» FOREIGN KEY («aux2.name.toString.toLowerCase») REFERENCES public.«aux.name.toString.toLowerCase» («aux2.name.toString.toLowerCase»);«ENDIF»«ENDFOR»«ELSEIF !(aux.is === null)»ALTER TABLE public.«relation.rightEnding.target.toString.toLowerCase» ADD CONSTRAINT fk_«relation.rightEnding.target.toString.toFirstUpper»_«relation.leftEnding.target.toString.toFirstUpper» FOREIGN KEY («FOR entityAux : e.entities»«IF entityAux.name.equalsIgnoreCase(aux.is.toString)»«FOR attAux : entityAux.attributes»«IF attAux.isIsKey»«attAux.name.toString.toLowerCase») REFERENCES public.«relation.leftEnding.target.toString.toLowerCase» («attAux.name.toString.toLowerCase»);«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»«ENDIF»«ENDFOR»«ENDIF»«ENDIF»«ENDFOR»'''
	
	
	private def mySQL_COUNT_FKsRelation1toN(ERModel e, String ename) { 
	'''«FOR relation : e.relations»
			«IF (((relation.leftEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:1)'))
								&& 
								(relation.rightEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:N)')))) 
								||
								(((relation.leftEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:N)'))
								&& 
								(relation.rightEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:1)'))))»	
				«IF relation.rightEnding.target.toString.equalsIgnoreCase(ename)»
					«FOR aux : e.entities»					
						«IF relation.leftEnding.target.toString.equalsIgnoreCase(aux.name)»
							«IF aux.is === null»
								«FOR attTest : aux.attributes»
									«IF attTest.isIsKey»
										«{globalFKcounter_1toN += 1; null}»
									«ENDIF»
								«ENDFOR»
							«ELSEIF !(aux.is === null)»
								«IF relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString)»
								«{globalFKcounter_1toN += 1; null}»
							«ELSEIF !relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString)»
							«{globalFKcounter_1toN += 1; null}»
						«ENDIF»
					«ENDIF»
				«ENDIF»
			«ENDFOR»
						«ENDIF»
					«ENDIF»
				«ENDFOR» 
«««========= TEM «globalFKcounter_1toN.toString» FKS 1 para N =========
	''' 
	}
	
	private def mySQLDefineFKsRelation1toN(ERModel e, String ename, int count) '''
		«FOR relation : e.relations»
			«IF (((relation.leftEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:1)'))
						&& 
						(relation.rightEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:N)')))) 
						||
						(((relation.leftEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:N)'))
						&& 
						(relation.rightEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:1)'))))»	
				«IF relation.rightEnding.target.toString.equalsIgnoreCase(ename)»
					«FOR aux : e.entities»
						«IF relation.leftEnding.target.toString.equalsIgnoreCase(aux.name)»
							«IF aux.is === null»
								«FOR attTest : aux.attributes»
									«IF attTest.isIsKey»
											ALTER TABLE public.«relation.rightEnding.target.toString.toLowerCase» ADD CONSTRAINT fk_«relation.rightEnding.target.toString.toFirstUpper»_«relation.leftEnding.target.toString.toFirstUpper» FOREIGN KEY («attTest.name.toString.toLowerCase») REFERENCES public.«aux.name.toString.toLowerCase» («attTest.name.toString.toLowerCase»);
									«ENDIF»
								«ENDFOR»
							«ELSEIF !(aux.is === null)»
								«IF relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString)»
									ALTER TABLE public.«relation.rightEnding.target.toString.toLowerCase» ADD CONSTRAINT fk_«relation.rightEnding.target.toString.toFirstUpper»_«relation.leftEnding.target.toString.toFirstUpper» FOREIGN KEY («relation.name.toString.toLowerCase») REFERENCES public.«relation.leftEnding.target.toString.toLowerCase» («FOR aux2 : e.entities»«IF aux2.name.equalsIgnoreCase(relation.leftEnding.target.toString)»«FOR aux3 : e.entities»«IF aux3.name.equalsIgnoreCase(aux2.is.toString)»«FOR aux4 : aux3.attributes»«IF aux4.isIsKey»«aux4.name.toString.toLowerCase»);«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»
								«ELSEIF !relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString)»
								ALTER TABLE public.«relation.rightEnding.target.toString.toLowerCase» ADD CONSTRAINT fk_«relation.rightEnding.target.toString.toFirstUpper»_«relation.leftEnding.target.toString.toFirstUpper» FOREIGN KEY («relation.leftEnding.target.toString.toLowerCase») REFERENCES public.«relation.leftEnding.target.toString.toLowerCase» («FOR aux2 : e.entities»«IF aux2.name.equalsIgnoreCase(relation.leftEnding.target.toString)»«FOR aux3 : e.entities»«IF aux3.name.equalsIgnoreCase(aux2.is.toString)»«FOR aux4 : aux3.attributes»«IF aux4.isIsKey»«aux4.name.toString.toLowerCase»);«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»
							«ENDIF»
						«ENDIF»
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDIF»
				«ENDFOR»
	'''
	
	private def mySQLHaveFK(ERModel e, Entity entity) '''
		«FOR relation : e.relations»
			«IF ((relation.leftEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:1)'))
				&& 
				(relation.rightEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:1)')))»
				«IF relation.rightEnding.target.toString.equalsIgnoreCase(entity.name.toString)»
					«FOR aux : e.entities»
						«IF relation.leftEnding.target.toString.equalsIgnoreCase(aux.name)»
							«IF aux.is === null»
								«FOR aux2 : aux.attributes»
									«IF aux2.isIsKey»«{myListFKs.add(aux2.name);""}»«ENDIF»
								«ENDFOR»
							«ELSEIF !(aux.is === null)»«{myListFKs.add(aux.is.toString);""}»«ENDIF»
						«ENDIF»
					«ENDFOR»
				«ENDIF»	
			«ELSEIF (((relation.leftEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:1)'))
						&& 
						(relation.rightEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:N)')))) 
						||
						(((relation.leftEnding.cardinality.equalsIgnoreCase('(0:N)') || relation.leftEnding.cardinality.equalsIgnoreCase('(1:N)'))
						&& 
						(relation.rightEnding.cardinality.equalsIgnoreCase('(0:1)') || relation.rightEnding.cardinality.equalsIgnoreCase('(1:1)'))))»
				«IF relation.rightEnding.target.toString.equalsIgnoreCase(entity.name.toString)»
					«FOR aux : e.entities»
						«IF relation.leftEnding.target.toString.equalsIgnoreCase(aux.name)»
							«IF aux.is === null»
								«FOR attTest : aux.attributes»
									«IF attTest.isIsKey»«{myListFKs.add(attTest.name);""}»«ENDIF»
								«ENDFOR»
							«ELSEIF !(aux.is === null)»
								«IF relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString)»
								«FOR aux2 : e.entities»«IF aux2.name.equalsIgnoreCase(relation.leftEnding.target.toString)»«FOR aux3 : e.entities»«IF aux3.name.equalsIgnoreCase(aux2.is.toString)»«FOR aux4 : aux3.attributes»«IF aux4.isIsKey»«{myListFKs.add(aux3.name);""}»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»
							«ELSEIF !relation.leftEnding.target.toString.equalsIgnoreCase(relation.rightEnding.target.toString)»
							«FOR aux2 : e.entities»«IF aux2.name.equalsIgnoreCase(relation.leftEnding.target.toString)»«FOR aux3 : e.entities»«IF aux3.name.equalsIgnoreCase(aux2.is.toString)»«FOR aux4 : aux3.attributes»«IF aux4.isIsKey»«{myListFKs.add(aux4.name);""}»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»«ENDIF»«ENDFOR»
						«ENDIF»
					«ENDIF»
				«ENDIF»
			«ENDFOR»
							«ENDIF»
			«ENDIF»			
			«ENDFOR»
	'''
	
}