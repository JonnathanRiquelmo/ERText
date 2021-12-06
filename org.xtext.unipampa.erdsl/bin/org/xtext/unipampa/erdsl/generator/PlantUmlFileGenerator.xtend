package org.xtext.unipampa.erdsl.generator

import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import org.xtext.unipampa.erdsl.erDsl.ERModel
import org.xtext.unipampa.erdsl.erDsl.Entity
import org.xtext.unipampa.erdsl.erDsl.Relation
import net.sourceforge.plantuml.SourceStringReader
import java.io.ByteArrayOutputStream
import org.eclipse.xtext.generator.IFileSystemAccessExtension3
import java.io.ByteArrayInputStream

class PlantUmlFileGenerator extends AbstractGenerator {
	
	override doGenerate(Resource input, IFileSystemAccess2 fsa, IGeneratorContext context) {
	
	val modeloER = input.contents.get(0) as ERModel
	
	try {

		for (diagramModel : input.contents.filter(typeof(ERModel))) {
			val plantUML = diagramModel.plotToPlantUML.toString
		
			if (fsa instanceof IFileSystemAccessExtension3) {
				val out = new ByteArrayOutputStream()
		
				new SourceStringReader(plantUML).generateImage(out)
		
				(fsa as IFileSystemAccessExtension3).generateFile(modeloER.domain.name.toLowerCase+"_Diagram.png",
		
					new ByteArrayInputStream(out.toByteArray))
		
				fsa.generateFile(modeloER.domain.name.toLowerCase+"_DiagramDesc_Gen.puml", plantUML)
		
			} else {
			
				fsa.generateFile(modeloER.domain.name.toLowerCase+"_DiagramDesc_PartialGen.puml", plantUML)
			}
		}
		
	} catch (Exception e) {
			
			println(e.stackTrace.toString)

	}

	}
	
	def private dispatch CharSequence plotToPlantUML(ERModel it) '''
    @startuml
    ' - Esconde os (*letra*) dos objetos (E para entidade, C para classe, O para objetos, etc)
    ' hide circle
    ' - workaround para evitar problemas com os angulos do crows foot
    ' skinparam linetype ortho
    skinparam titleBorderRoundCorner 15
    skinparam titleBorderThickness 1
    ' skinparam titleBorderColor red
    scale 1.0
    ' skinparam monochrome true
    header
    <b>Diagram generated by ERtext</b>
    endheader
    right footer <b>https://github.com/ProjetoDSL/ERDSL</b>
    title <b>«domain.name.toUpperCase»</b>\n(conceptual model)
    «FOR e : entities»
    «e.plotToPlantUML»
    «ENDFOR»
«««    «FOR r : relations»
«««    «IF (r.leftEnding.cardinality.equalsIgnoreCase("(0:N)") || r.leftEnding.cardinality.equalsIgnoreCase("(1:N)")) && (r.rightEnding.cardinality.equalsIgnoreCase("(0:N)") || r.rightEnding.cardinality.equalsIgnoreCase("(1:N)"))»
«««    entity «r.name.toLowerCase» {
«««    }
«««    «ENDIF»
«««    «ENDFOR»
    «FOR r : relations»
    «r.plotToPlantUML»
    «ENDFOR»
    «FOR e : entities»
    «IF !(e.is === null)»«e.name.toString.toLowerCase» --|> «e.is.name.toString.toLowerCase»«ENDIF»
    «ENDFOR»
    @enduml
    '''
     
    def private dispatch CharSequence plotToPlantUML(Entity it) '''
    entity «name.toLowerCase» {
        «FOR att : attributes»
    «IF att.isKey»* «att.name.toLowerCase» : «att.type.toString.toLowerCase»
    --
    «ELSE»«att.name.toLowerCase» : «att.type.toString.toLowerCase»«ENDIF» 
        «ENDFOR»
    }
    
    '''

//		Type		|	Symbol
//	Zero or One		|	|o--
//	Exactly One		|	||--
//	Zero or Many	|	}o--
//	One or Many		|	}|--
    
    def private dispatch CharSequence plotToPlantUML(Relation it) ''' 
«««    	«leftEnding.target.toString.toLowerCase» «defineLeftCardinalitySymbolUML(leftEnding.cardinality.toString)»--«defineRightCardinalitySymbolUML(rightEnding.cardinality.toString)» «rightEnding.target.toString.toLowerCase» : "«name.toString.toLowerCase»"
		«IF leftEnding.target instanceof Entity && rightEnding.target instanceof Entity»
		diamond «name.toLowerCase»_dmd
		«leftEnding.target.toString.toLowerCase» «defineLeftCardinalitySymbolUML(leftEnding.cardinality.toString)»-- «name.toLowerCase»_dmd
		«name.toLowerCase»_dmd --«defineRightCardinalitySymbolUML(rightEnding.cardinality.toString)» «rightEnding.target.toString.toLowerCase»
		«ENDIF»
		«IF !(leftEnding.target instanceof Entity) || !(rightEnding.target instanceof Entity)»
			«IF leftEnding.target instanceof Relation»
				«leftEnding.target.toString.toLowerCase»_dmd --«defineRightCardinalitySymbolUML(rightEnding.cardinality.toString)» «rightEnding.target.toString.toLowerCase»
				note "Ternary\n  Relationship" as N_«leftEnding.target.toString.toLowerCase»_dmd
				N_«leftEnding.target.toString.toLowerCase»_dmd .. «leftEnding.target.toString.toLowerCase»_dmd
			«ELSEIF rightEnding.target instanceof Relation»
				«leftEnding.target.toString.toLowerCase» «defineLeftCardinalitySymbolUML(leftEnding.cardinality.toString)»-- «rightEnding.target.toString.toLowerCase»_dmd
				note "Ternary\n  Relationship" as N_«rightEnding.target.toString.toLowerCase»_dmd
				N_«rightEnding.target.toString.toLowerCase»_dmd .. «rightEnding.target.toString.toLowerCase»_dmd
			«ENDIF»
		«ENDIF»
		
    '''
    
//    def defineLeftCardinalitySymbolUML(String cd)'''«IF cd.equalsIgnoreCase("(0:1)")» |o«ELSEIF cd.equalsIgnoreCase("(1:1)")» ||«ELSEIF cd.equalsIgnoreCase("(0:N)")» }o«ELSEIF cd.equalsIgnoreCase("(1:N)")» }|«ENDIF»'''
	def private defineLeftCardinalitySymbolUML(String cd)'''«IF cd.equalsIgnoreCase("(0:1)")»"(0:1)" «ELSEIF cd.equalsIgnoreCase("(1:1)")»"(1:1)" «ELSEIF cd.equalsIgnoreCase("(0:N)")»"(0:N)" «ELSEIF cd.equalsIgnoreCase("(1:N)")»"(1:N)" «ENDIF»'''
    
//    def defineRightCardinalitySymbolUML(String cd)'''«IF cd.equalsIgnoreCase("(0:1)")»o| «ELSEIF cd.equalsIgnoreCase("(1:1)")»|| «ELSEIF cd.equalsIgnoreCase("(0:N)")»o{ «ELSEIF cd.equalsIgnoreCase("(1:N)")»|{ «ENDIF»'''
	def private defineRightCardinalitySymbolUML(String cd)'''«IF cd.equalsIgnoreCase("(0:1)")» "(0:1)"«ELSEIF cd.equalsIgnoreCase("(1:1)")» "(1:1)" «ELSEIF cd.equalsIgnoreCase("(0:N)")» "(0:N)" «ELSEIF cd.equalsIgnoreCase("(1:N)")» "(1:N)" «ENDIF»'''
	
}