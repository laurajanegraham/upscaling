calc_commonality <-function (glm_obj){
  
  ##DESCRIPTION
  ##Returns a list of two tables.
  ##The first table (CC) contains the list of commonality coefficents and % of variance for each effect.
  ##The second table (CCTotalByVar) totals the unique and common effects for each independent variable.
  ##REQUIRED ARGUMENTS
  ## glm_obj: this is a fitted glm 
  ##PSEUDO CODE
  ## Determine the number of independent variables (n).
  ## Generate an ID for each independent variable to 2^(n-1).
  ## For example, the ID of the 1st independent variable is 2^0 =1.
  ## Determine the number of commonality coefficients (2^n-1).
  ## Generate a bitmap matrix containing the bit representation of each commonality coefficient.
  ## Use the bitmap matrix to compute the R2 value for each combination of independent variables.
  ## Store the R2 value based on an index that is computed by ORing the IDs of the related IV.
  ## Use the bitmap matrix to generate the list of R2 values needed for each commonality coefficient.
  ## Use the list of R2 values to compute each commonality coefficient.
  ## Calculate the % explained variance for each commonality coefficient.
  ## Use the bitmap matrix to generate row headings for the first output table.
  ## Use the bitmap matrix to total the commonality coefficient effects by variable.
  ## Return the list of two tables.
  
  ## NB R2 currently based on 1 - (deviance / null.deviance)
  ## Get the variables for the analysis from the model object
  
  model_frame <- model.frame(glm_obj)
  dataMatrix <- cbind(model_frame[,1], model.matrix(glm_obj)[,-1])
  colnames(dataMatrix)[1] <- colnames(model_frame)[1]
  dv <- colnames(dataMatrix)[1]
  ivlist <- colnames(dataMatrix)[2:ncol(dataMatrix)]
  mod_type <- class(glm_obj)[1]
  
  
  
  ## Determine the number of independent variables.
  ivlist <- unlist(ivlist)
  nvar=length(ivlist)
  ## Generate an ID for each independent variable to 2^(n-1).
  ivID <- matrix(nrow=nvar,ncol=1)
  for (i in 0: nvar-1){
    ivID[i+1]=2^i
  }
  
  ## Determine the number of commonality coefficients.
  numcc=2**nvar-1
  ## Generate a matrix containing the bit representation of each commonality coefficient
  effectBitMap<-matrix(0, nvar, numcc)
  for (i in 1:numcc){
    effectBitMap<-setBits(i, effectBitMap)
  }
  
  ## Use the bitmap matrix to compute the R2 value for each combination of independent variables
  ## Store the R2 value based on an index that is computing by ORing the IDs of the related IVs.
  commonalityMatrix <- matrix(nrow=numcc,ncol=3)
  for (i in 1: numcc){
    formula=paste(dv,"~", sep="")
    for (j in 1: nvar){
      bit = effectBitMap[j,i]
      if (bit == 1){
        formula=paste(formula,paste("+",ivlist[[j]], sep=""), sep="")
      }
    }
    if(mod_type == "lm") {
      commonalityMatrix[i,2]<-summary(lm(formula,data.frame(dataMatrix)))$r.squared  
    } else if(mod_type == "glm") {
      mod_family <- glm_obj$family$family
      sub_mod <- glm(formula,family = mod_family, data = data.frame(dataMatrix))
      r2 <- 1 - (sub_mod$deviance / sub_mod$null.deviance)
      commonalityMatrix[i,2]<-r2
    } else if(mod_type == "negbin") {
      sub_mod <- glm.nb(formula = formula, data = data.frame(dataMatrix))
      r2 <- 1 - (sub_mod$deviance / sub_mod$null.deviance)
      commonalityMatrix[i,2]<-r2
    } else {
      "STOP! Model type not supported, model should be glm or lm"
    }
    
  }

  ## Use the bitmap matrix to generate the list of R2 values needed.
  commonalityList<-vector("list", numcc)
  for (i in 1: numcc){
    bit = effectBitMap[1,i]
    if (bit == 1) ilist <-c(0,-ivID[1])
    else ilist<-ivID[1]
    for (j in 2: nvar){
      bit = effectBitMap[j,i]
      if (bit == 1){
        alist<-ilist
        blist<-genList(ilist,-ivID[j])
        ilist<-c(alist,blist)
      }
      else ilist<-genList(ilist,ivID[j])
    }
    ilist<-ilist*-1
    commonalityList[[i]]<-ilist
  }
  
  ## Use the list of R2 values to compute each commonality coefficient.
  for (i in 1: numcc){
    r2list <- unlist(commonalityList[i])
    numlist = length(r2list)
    ccsum=0
    for (j in 1:numlist){
      indexs = r2list[[j]]
      indexu = abs (indexs)
      if (indexu !=0) {
        ccvalue = commonalityMatrix[indexu,2]
        if (indexs < 0)ccvalue = ccvalue*-1
        ccsum=ccsum+ccvalue
      }
    }
    commonalityMatrix[i,3]=ccsum
  }
  
  ## Calculate the % explained variance for each commonality coefficient.
  orderList<-vector("list", numcc)
  index=0
  for (i in 1:nvar){
    for (j in 1:numcc){
      nbits=sum(effectBitMap[,j])
      if (nbits == i){
        index=index+1
        commonalityMatrix[index,1]<-j
      }
    }
  }
  
  ## Prepare first output table.
  outputCommonalityMatrix <- matrix(nrow=numcc+1,ncol=2)
  totalRSquare <- sum(commonalityMatrix[,3])
  for (i in 1:numcc){
    outputCommonalityMatrix[i,1]<-round(commonalityMatrix[commonalityMatrix[i,1],3], digit=4)
    outputCommonalityMatrix[i,2]<-
      round((commonalityMatrix[commonalityMatrix[i,1],3]/totalRSquare)*100, digit=2)
  }
  outputCommonalityMatrix[numcc+1,1]<-round(totalRSquare,digit=4)
  outputCommonalityMatrix[numcc+1,2]<-round(100,digit=4)
  ## Use the bitmap matrix to generate row headings for the first output table.
  rowNames=NULL
  for (i in 1: numcc){
    ii=commonalityMatrix[i,1]
    nbits=sum(effectBitMap[,ii])
    cbits=0
    if (nbits==1) rowName="Unique to "
    else rowName = "Common to "
    for (j in 1:nvar){
      if (effectBitMap[j,ii]==1){
        if (nbits==1)rowName=paste(rowName,ivlist[[j]],sep= "")
        else {
          cbits=cbits+1
          if (cbits==nbits){
            rowName=paste(rowName,"and ", sep="")
            rowName=paste(rowName,ivlist[[j]],sep="")
          }
          else{
            rowName=paste(rowName,ivlist[[j]],sep="")
            rowName=paste(rowName,",", sep="")
          }
        }
      }
    }
    rowNames=c(rowNames,rowName)
  }
  rowNames=c(rowNames,"Total")
  rowNames<-format.default(rowNames,justify="left")
  colNames<-format.default(c ("Coefficient", " % Total"), justify="right")
  dimnames(outputCommonalityMatrix)<-list(rowNames,colNames)
  
  ## Use the bitmap matrix to total the commonality coefficient effects by variable.
  outputCCbyVar<-matrix(nrow=nvar,ncol=3)
  for (i in 1:nvar){
    outputCCbyVar[i,1]=outputCommonalityMatrix[i,1]
    outputCCbyVar[i,3]=round(sum(effectBitMap[i,]*commonalityMatrix[,3]), digit=4)
    outputCCbyVar[i,2]=outputCCbyVar[i,3]-outputCCbyVar[i,1]
  }
  dimnames(outputCCbyVar)<-list(ivlist,c("Unique", "Common", "Total"))
  ## Return the list of two output tables.
  outputList<-list(CC=outputCommonalityMatrix, CCTotalbyVar=outputCCbyVar)
  return (outputList)
}
  
  #########################################################################
  setBits<-function(col, effectBitMap) {
    #########################################################################
    ##DESCRIPTION
    ##Creates the binary representation of n and stores it in the nth column of the matrix
    ##REQUIRED ARGUMENTS
    ##col Column of matrix to represent in binary image
    ##effectBitMap Matrix of mean combinations in binary form
    ##Initialize variables
    row<-1
    val<-col
    ##Create the binary representation of col and store it in its associated column
    ##One is stored in col 1; Two is stored in col 2; etc.
    ##While (val >= 1)
    ## If the LSB of val is 1; increment the appropriate entry in combo matrix
    ## Shift the LSB of val to the right
    while (val!=0){
      if (odd(val)) {
        effectBitMap[row,col]=1
      }
      val<-as.integer(val/2)
      row<-row+1
    }
    ##Return matrix
    return(effectBitMap)
  }
  #########################################################################
  odd<-function(val) {
    #########################################################################
    ##DESCRIPTION
    ##Returns true if value is odd; false if true
    ##REQUIRED ARGUMENTS
    ##val Value to check
    ##Returns true if val is odd
    if (((as.integer(val/2))*2)!=val) return(TRUE)
    return (FALSE)
    
  }
  #########################################################################
  genList<-function(ivlist, value){
    #########################################################################
    numlist = length(ivlist)
    newlist<-ivlist
    newlist=0
    for (i in 1:numlist){
      newlist[i]=abs(ivlist[i])+abs(value)
      if(((ivlist[i]<0) && (value >= 0))|| ((ivlist[i]>=0) && (value <0)))newlist[i]=newlist[i]*-1
    }
    return(newlist)
  }