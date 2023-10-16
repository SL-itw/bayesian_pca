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
}
//transformed data{ //standardizes the data in case it isn't

//  vector[p] x_means;
//  vector[p] x_sds;
//  matrix[N,p] x_norm;

//  for(i in 1:p){
//    x_means[i] = mean(x[:,i]);
//    x_sds[i] = sd(x[:,i]);
//    x_norm[:,i] = (x[:,i] - x_means[i])/x_sds[i];
//  }
//}

// The parameters accepted by the model.
parameters {
  vector[p] mu;
  matrix[p,q] B;
  //real<lower=0> sigma;
  matrix[N,q] z; // the first will be the smallest
  vector<lower = 0>[q] lambda;

}
transformed parameters {
  vector<lower=0>[q] t_lambda;
  t_lambda = inv(sqrt(lambda));
}

// The model to be estimated. We model the output
// 'y' to be normally distributed with mean 'mu'
// and standard deviation 'sigma'.
model {

   // sigma ~ gamma(1,1);
		to_vector(z) ~ normal(0,1);
	//	lambda ~ gamma(a,b);
	//	for(j in 1:q) B[,j] ~ normal(0, t_lambda[j]);


  lambda ~ gamma(a,b);
  for(i in 1:q){
  z[i,] ~ normal(0,1); // identity matrix explained
  }
   mu ~ normal(0,1);
   for(i in 1:q){
   B[,i] ~ normal(0,t_lambda[i]);
  }

 // for(i in 1:p){ // c++ prefers column wise operations
 // x[,i] ~ normal(B[i,:]*z+mu[i], 1 ); // identity matrix implied
 // }

  		to_vector(x) ~ normal(to_vector(z*B'), 1);

}generated quantities{
  matrix[N,p] preds;

  for(i in 1:p){
    for(j in 1:N){
    preds[j,i] = normal_rng((B[i,:]*z[j]'),1);
    }
  }

}


