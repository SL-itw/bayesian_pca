//
// This Stan program defines a simple model, with a
// vector of values 'y' modeled as normally distributed
// with mean 'mu' and standard deviation 'sigma'.
//
// Learn more about model development with Stan at:
//
//    http://mc-stan.org/users/interfaces/rstan.html
//    https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started
//

// The input data is a vector 'y' of length 'N'.
data {
  int<lower=0> N; //number of subjects
  int q; // number of reduced PC of covariates
  int p; // number of covariates
  matrix[N,p] x;//design matrix
  real a;
  real b;
}transformed data{ //standardizes the data in case it isn't 
  
  vector[p] x_means;
  vector[p] x_sds;
  matrix[N,p] x_norm;
  
  for(i in 1:p){
    x_means[i] = mean(x[:,i]);
    x_sds[i] = sd(x[:,i]);
    x_norm[:,i] = (x[:,i] - x_means[i])/x_sds[i];
  }
}

// The parameters accepted by the model. Our model
// accepts two parameters 'mu' and 'sigma'.
parameters {
  vector[p] mu;
  matrix[p,q] B; 
  real<lower=0> sigma;
  positive_ordered[q] z; // the first will be the smallest
  vector<lower = 0>[q] alpha;
  
}


// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {
  
  vector[p] mus;
  
  mus = B*z;
  
  for(i in 1:p){ // c++ prefers column wise operations
  x_norm[,i] ~ normal(mus[i],sigma ); // identity matrix implied; not includeding mean assuming standardization everywhere
  }
  
  alpha ~ gamma(a,b);
  z ~ normal(0,1); // identity matrix explained 
  for(i in 1:q){
  B[,i] ~ normal(0,alpha[i]);
  }
}generated quantities{
  matrix[N,p] preds;
  
  for(i in 1:p){
    for(j in 1:N){
    preds[j,i] = normal_rng(B[i,:]*z,sigma);
    }
  }
  
}

